;;; anki-setup.el --- Anki workflow for student faces -*- lexical-binding: t; -*-

(require 'anki-editor)
(require 'cl-lib)
(require 'org)
(require 'subr-x)

(defgroup my/anki nil
  "Anki integration for Org files."
  :group 'anki-editor)

(defcustom my/anki-root-directory (expand-file-name "~/emacs/anki/")
  "Root directory whose .anki paths form the Anki deck hierarchy.
For example, students/29Ba.anki maps to students::29Ba."
  :type 'directory
  :group 'my/anki)

(defcustom my/anki-startup-timeout 20
  "Seconds to wait for AnkiConnect after starting Anki."
  :type 'number
  :group 'my/anki)

(defvar-local my/anki--syncing nil)

(defun my/anki-running-p ()
  "Return non-nil when AnkiConnect responds."
  (condition-case nil
      (progn
        (anki-editor-api-call-result 'version)
        t)
    (error nil)))

(defun my/anki--windows-executable ()
  "Return the path to Anki on Windows, or nil when it cannot be found."
  (let ((local-app-data (getenv "LOCALAPPDATA"))
        (program-files (getenv "ProgramFiles"))
        (program-files-x86 (getenv "ProgramFiles(x86)")))
    (or (executable-find "anki")
        (cl-find-if
         #'file-executable-p
         (delq nil
               (list
                (and local-app-data
                     (expand-file-name "Programs/Anki/anki.exe" local-app-data))
                (and local-app-data
                     (expand-file-name "Anki/anki.exe" local-app-data))
                (and program-files
                     (expand-file-name "Anki/anki.exe" program-files))
                (and program-files-x86
                     (expand-file-name "Anki/anki.exe" program-files-x86))))))))

(defun my/anki--start ()
  "Start Anki and return its process."
  (let ((process
         (pcase system-type
           ('darwin
            (start-process "anki" nil "open" "-a" "Anki"))
           ('windows-nt
            (if-let* ((executable (my/anki--windows-executable)))
                (start-process "anki" nil executable)
              (user-error "Could not find an Anki installation")))
           (_
            (if-let* ((executable (executable-find "anki")))
                (start-process "anki" nil executable)
              (user-error "Could not find the Anki executable"))))))
    (set-process-query-on-exit-flag process nil)
    process))

(defun my/ensure-anki-running (&optional timeout)
  "Start Anki when needed and wait up to TIMEOUT seconds for AnkiConnect."
  (interactive)
  (unless (my/anki-running-p)
    (message "Starting Anki...")
    (my/anki--start)
    (let ((deadline (+ (float-time) (or timeout my/anki-startup-timeout))))
      (while (and (< (float-time) deadline)
                  (not (my/anki-running-p)))
        (accept-process-output nil 0.5)))
    (unless (my/anki-running-p)
      (user-error
       "AnkiConnect did not respond; install or enable add-on 2055492159"))
    (message "Anki is ready"))
  (anki-editor-api-check))

(defun my/anki-deck-from-path ()
  "Return the deck represented by the current file's path.
Each path component becomes a deck component and the .anki suffix is removed."
  (when buffer-file-name
    (let ((root (file-name-as-directory
                 (expand-file-name my/anki-root-directory)))
          (file (expand-file-name buffer-file-name)))
      (when (file-in-directory-p file root)
        (let ((relative-file (file-relative-name file root)))
          (string-join
           (split-string (file-name-sans-extension relative-file) "[/\\\\]" t)
           "::"))))))

(defun my/anki-set-deck-from-folder ()
  "Set the inherited Anki deck from the current file's directory."
  (if-let* ((deck (my/anki-deck-from-path)))
      (progn
        (setq-local org-global-properties
                    (cons (cons anki-editor-prop-deck deck)
                          (cl-remove anki-editor-prop-deck
                                     org-global-properties
                                     :key #'car
                                     :test #'string=)))
        (message "Anki deck set to: %s" deck))
    (message "Anki deck not set: file is outside %s"
             (abbreviate-file-name my/anki-root-directory))))

(defun my/anki-sync-collection ()
  "Sync Anki with AnkiWeb, warning instead of failing when offline."
  (condition-case error-data
      (progn
        (anki-editor-sync-collection)
        t)
    (error
     (display-warning
      'my/anki
      (format "Could not sync AnkiWeb: %s" (error-message-string error-data)))
     nil)))

(defun my/anki-open ()
  "Start Anki if needed, or activate its existing instance."
  (interactive)
  (let ((was-running (my/anki-running-p)))
    (my/ensure-anki-running)
    (when was-running
      (my/anki--start))))

(defun my/anki-browse ()
  "Ensure Anki is running and browse the current note or deck."
  (interactive)
  (my/ensure-anki-running)
  (call-interactively #'anki-editor-gui-browse))

(defun my/anki-quit-mode ()
  "Disable `anki-editor-mode' in the current buffer."
  (interactive)
  (anki-editor-mode -1)
  (message "Anki editor mode disabled"))

(defun my/anki-auto-sync ()
  "Push new and changed notes, then sync AnkiWeb after saving."
  (when (and anki-editor-mode (not my/anki--syncing))
    (let ((my/anki--syncing t))
      (my/ensure-anki-running)
      (message "Pushing notes to Anki...")
      (anki-editor-push-notes 'file)
      (my/anki-sync-collection))))

(defun my/anki-mode-setup ()
  "Configure Org and anki-editor for the current .anki file."
  (my/anki-set-deck-from-folder)
  (my/ensure-anki-running)
  (my/anki-sync-collection)
  (anki-editor-mode 1)
  (add-hook 'after-save-hook #'my/anki-auto-sync nil t))

(defun my/anki-insert-student (name hobbies image-path)
  "Insert a Basic note for a student with NAME, HOBBIES, and IMAGE-PATH."
  (interactive "sStudent name: \nsHobbies: \nfImage file: ")
  (unless (and buffer-file-name
               (string-match-p "\\.anki\\'" buffer-file-name))
    (user-error "This command is only available in .anki files"))
  (my/ensure-anki-running)
  (let ((heading (replace-regexp-in-string "[\n\r]+" " " (string-trim name)))
        (image-link
         (org-link-make-string
          (concat "file:" (expand-file-name image-path)))))
    (insert (format (concat "* %s\n"
                            ":PROPERTIES:\n"
                            ":ANKI_NOTE_TYPE: Basic\n"
                            ":END:\n"
                            "** Front\n"
                            "%s\n"
                            "** Back\n"
                            "*Name:* %s\n"
                            "*Hobbies:* %s\n\n")
                    heading image-link name hobbies)))
  (message "Student note inserted; save the file to push it to Anki"))

(add-to-list 'auto-mode-alist '("\\.anki\\'" . org-mode))
(add-hook 'org-mode-hook
          (defun my/anki-enable-for-anki-file ()
            "Enable the student Anki workflow for .anki files."
            (when (and buffer-file-name
                       (string-match-p "\\.anki\\'" buffer-file-name))
              (my/anki-mode-setup))))

(map! :map anki-editor-mode-map
      :localleader
      :desc "Quit Anki mode" "q" #'my/anki-quit-mode
      (:prefix ("a" . "Anki")
       :desc "Browse note or deck" "b" #'my/anki-browse
       :desc "Open Anki" "o" #'my/anki-open))

(provide 'anki-setup)
;;; anki-setup.el ends here
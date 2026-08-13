;;; anki-setup.el --- Anki workflow for student faces -*- lexical-binding: t; -*-

(require 'anki-editor)
(require 'cl-lib)
(require 'org)
(require 'org-download)
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

(defun my/anki--deck-note-ids ()
  "Return the Anki note IDs in the current file's deck."
  (if-let* ((deck (my/anki-deck-from-path)))
      (anki-editor-api-call-result
       'findNotes :query (format "deck:\"%s\"" deck))
    (user-error "Current file does not map to an Anki deck")))

(defun my/anki--file-note-ids ()
  "Return the Anki note IDs represented in the current buffer."
  (delq nil
        (org-map-entries
         (lambda ()
           (when-let* ((note-id (org-entry-get nil anki-editor-prop-note-id)))
             (string-to-number note-id)))
         (concat "+" anki-editor-prop-note-type "<>\"\"")
         nil)))

(defun my/anki-delete-removed-notes ()
  "Delete deck notes from Anki that are absent from the current file."
  (let ((removed-note-ids
         (cl-set-difference (my/anki--deck-note-ids)
                            (my/anki--file-note-ids)
                            :test #'=)))
    (when removed-note-ids
      (anki-editor-api-call-result 'deleteNotes :notes removed-note-ids)
      (message "Deleted %d removed notes from Anki"
               (length removed-note-ids)))))

(defun my/anki-quit-mode ()
  "Disable `anki-editor-mode' in the current buffer."
  (interactive)
  (anki-editor-mode -1)
  (message "Anki editor mode disabled"))

(defun my/anki-auto-sync ()
  "Mirror the current file to Anki, then sync AnkiWeb after saving."
  (when (and anki-editor-mode (not my/anki--syncing))
    (let ((my/anki--syncing t))
      (my/ensure-anki-running)
      (my/anki-delete-removed-notes)
      (message "Pushing notes to Anki...")
      (anki-editor-push-notes 'file)
      (my/anki-sync-collection))))

(defun my/anki-mode-setup ()
  "Configure Org and anki-editor for the current .anki file."
  (my/anki-set-deck-from-folder)
  (setq-local org-download-method 'directory
              org-download-image-dir
              (expand-file-name
               (concat (file-name-base buffer-file-name) "-images")
               (file-name-directory buffer-file-name))
              org-download-heading-lvl nil
              org-download-display-inline-images t
              org-startup-with-inline-images t)
  (my/ensure-anki-running)
  (my/anki-sync-collection)
  (anki-editor-mode 1)
  (add-hook 'after-save-hook #'my/anki-auto-sync nil t)
  (org-display-inline-images))

(defun my/anki-create-file (deck)
  "Create or open the .anki file for DECK below `my/anki-root-directory'.
DECK may use slashes or Anki's double-colon separator."
  (interactive (list (read-string "Anki deck (for example students/Gb30): ")))
  (let* ((deck (string-remove-suffix ".anki" (string-trim deck)))
         (relative-path (replace-regexp-in-string "::" "/" deck))
         (components (split-string relative-path "/" t)))
    (when (or (string-empty-p relative-path)
              (file-name-absolute-p relative-path)
              (seq-some (lambda (component)
                          (member component '("." "..")))
                        components))
      (user-error "Invalid Anki deck path: %s" deck))
    (let ((anki-file
           (expand-file-name (concat relative-path ".anki")
                             my/anki-root-directory)))
      (make-directory (file-name-directory anki-file) t)
      (find-file anki-file))))

(defun my/anki-open-file (file)
  "Open an existing .anki FILE and enable its Anki workflow."
  (interactive
   (list
    (read-file-name
     "Open Anki file: " my/anki-root-directory nil t nil
     (lambda (candidate)
       (or (file-directory-p candidate)
           (string-match-p "\\.anki\\'" candidate))))))
  (unless (string-match-p "\\.anki\\'" file)
    (user-error "Not an .anki file: %s" file))
  (find-file file))

(defun my/anki-read-rating (label)
  "Read a rating for LABEL between 1 and 10, or 0 for empty."
  (let ((rating -1))
    (while (not (and (integerp rating) (<= 0 rating 10)))
      (setq rating (read-number (format "%s (0-10): " label))))
    rating))

(defun my/anki-insert-student-template
    (name good-to-know expectation leisure feedback)
  "Insert a student card using the supplied details and clipboard image."
  (interactive (list (read-string "Student name: ")
                     (read-string "Gut zu wissen: ")
                     (my/anki-read-rating "Erwartung")
                     (my/anki-read-rating "Freizeit")
                     (read-string "Feedback 1: ")))
  (unless (and buffer-file-name
               (string-match-p "\\.anki\\'" buffer-file-name)
               anki-editor-mode)
    (user-error "Open an .anki file before inserting a student card"))
  (unless (executable-find "pngpaste")
    (user-error "Install pngpaste before inserting a student card"))
  (setq name (replace-regexp-in-string "[\n\r]+" " " (string-trim name))
        good-to-know
        (replace-regexp-in-string "[\n\r]+" " " (string-trim good-to-know))
        feedback
        (replace-regexp-in-string "[\n\r]+" " " (string-trim feedback)))
  (when (string-empty-p name)
    (user-error "Student name cannot be empty"))
  (unless (and (integerp expectation) (<= 0 expectation 10)
               (integerp leisure) (<= 0 leisure 10))
    (user-error "Erwartung and Freizeit must be integers from 0 to 10"))
  (unless (bolp)
    (end-of-line)
    (insert "\n"))
  (let ((card-start (point))
        (class-name (file-name-base buffer-file-name)))
    (insert (format (concat "* %s\n"
                            ":PROPERTIES:\n"
                            ":ANKI_NOTE_TYPE: Basic\n"
                            ":END:\n"
                            "** Front\n"
                            "** Back\n"
                            "*Name:* %s\n"
                            "*Gut zu wissen:* %s\n"
                            "*Erwartung:* %s\n"
                            "*Freizeit:* %s\n"
                                "*Klasse:* %s\n"
                            "*Feedback 1:* %s\n")
                              name name good-to-know
                              (if (zerop expectation) "" expectation)
                              (if (zerop leisure) "" leisure)
                              class-name feedback))
    (save-excursion
      (goto-char card-start)
      (search-forward "** Front\n")
      (my/anki-paste-image))))

(defun my/anki-paste-image ()
  "Paste a clipboard image at point in the current .anki file."
  (interactive)
  (unless (and buffer-file-name
               (string-match-p "\\.anki\\'" buffer-file-name)
               anki-editor-mode)
    (user-error "Open an .anki file before pasting an image"))
  (unless (executable-find "pngpaste")
    (user-error "Install pngpaste before pasting clipboard images"))
  (when (org-in-regexp "\\[\\[file:/path/to/photo\\.jpg\\]\\]")
    (delete-region (match-beginning 0) (match-end 0)))
  (let ((org-download-method 'directory)
        (org-download-image-dir
         (expand-file-name
          (concat (file-name-base buffer-file-name) "-images")
          (file-name-directory buffer-file-name)))
        (org-download-heading-lvl nil)
        (org-download-annotate-function (lambda (_) ""))
        (org-download-link-format "[[file:%s]]\n")
        (org-download-link-format-function
         #'org-download-link-format-function-default)
        (org-download-abbreviate-filename-function #'file-relative-name))
    (cl-letf (((symbol-function #'org-id-get-create) #'ignore))
      (org-download-clipboard))))

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
   :desc "Insert student card" "i" #'my/anki-insert-student-template
   :desc "Paste student photo" "p" #'my/anki-paste-image))

(map! :leader
      (:prefix ("m" . "Local")
   (:prefix ("a" . "Anki")
    :desc "New Anki file" "n" #'my/anki-create-file
    :desc "Open Anki file" "o" #'my/anki-open-file)))

(provide 'anki-setup)
;;; anki-setup.el ends here
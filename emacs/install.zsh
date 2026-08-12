phase_1_admin_installs() {
  install_brewfile emacs/Brewfile
  # brew sets quarantine on all casks; strip it so non-interactive emacs --batch isn't SIGKILL'd
  [[ -d /Applications/Emacs.app ]] && xattr -dr com.apple.quarantine /Applications/Emacs.app
}

phase_3_dotfiles() {
  link_dotfile "emacs/.zshenv" "$HOME/.zshenv.d/zshenv_emacs"
}

install_macos_emacs_daemon() {
  [[ "$OSTYPE" == darwin* ]] || return 0

  local emacs_executable label plist launchctl_domain emacs_daemon_path
  if [[ -x /Applications/Emacs.app/Contents/MacOS/Emacs ]]; then
    emacs_executable=/Applications/Emacs.app/Contents/MacOS/Emacs
  else
    emacs_executable="$(command -v emacs)" || {
      echo "emacs executable not found."
      return 1
    }
  fi

  label=emacs-daemon
  plist="$HOME/Library/LaunchAgents/$label.plist"
  [[ -f "$plist" ]] && return 0
  mkdir -p "${plist:h}"
  mkdir -p "$HOME/Library/Logs"
  emacs_daemon_path="/opt/homebrew/opt/ccache/libexec:$PATH:$HOME/.config/emacs/bin"
  plutil -create xml1 "$plist"
  plutil -insert Label -string "$label" "$plist"
  plutil -insert ProgramArguments -array "$plist"
  plutil -insert ProgramArguments.0 -string "$emacs_executable" "$plist"
  plutil -insert ProgramArguments.1 -string --daemon "$plist"
  plutil -insert RunAtLoad -bool true "$plist"
  plutil -insert KeepAlive -bool false "$plist"
  plutil -insert EnvironmentVariables -dictionary "$plist"
  plutil -insert EnvironmentVariables.DOOMDIR -string "$HOME/.config/doom" "$plist"
  plutil -insert EnvironmentVariables.PATH -string "$emacs_daemon_path" "$plist"
  plutil -insert StandardOutPath -string "$HOME/Library/Logs/$label.out.log" "$plist"
  plutil -insert StandardErrorPath -string "$HOME/Library/Logs/$label.err.log" "$plist"

  launchctl_domain="gui/$(id -u)"
  launchctl bootout "$launchctl_domain" "$plist" > /dev/null 2>&1 || true
  launchctl bootstrap "$launchctl_domain" "$plist"
  launchctl enable "$launchctl_domain/$label"
  launchctl kickstart -k "$launchctl_domain/$label" > /dev/null 2>&1 || true
}

phase_4_post_dotfiles() {
  if [ ! -f ~/.config/emacs/bin/doom ]; then
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install --env
  fi

  mkdir -p ~/.config/doom
  ~/.config/emacs/bin/doom upgrade --force
  link_dotfile "emacs/anki-setup.el" "$HOME/emacs/anki/anki-setup.el"
  link_dotfile "emacs/.config/doom/cheatsheet.org" "$HOME/.config/doom/cheatsheet.org"
  link_dotfile "emacs/.config/doom/config.org" "$HOME/.config/doom/config.org"
  link_dotfile "emacs/.config/doom/init.el" "$HOME/.config/doom/init.el"
  link_dotfile "emacs/.config/doom/packages.el" "$HOME/.config/doom/packages.el"
  ~/.config/emacs/bin/doom sync
  install_macos_emacs_daemon
}

phase_1_admin_installs() {
  install_brewfile emacs/Brewfile
  # brew sets quarantine on all casks; strip it so non-interactive emacs --batch isn't SIGKILL'd
  [[ -d /Applications/Emacs.app ]] && xattr -dr com.apple.quarantine /Applications/Emacs.app
}

phase_3_dotfiles() {
  link_dotfile "emacs/.zshenv" "$HOME/.zshenv.d/zshenv_emacs"
  link_dotfile "emacs/.zshrc.d/40_emacs_client.zsh" "$HOME/.zshrc.d/40_emacs_client.zsh"
}

install_macos_emacs_daemon() {
  [[ "$OSTYPE" == darwin* ]] || return 0

  local emacs_executable label=emacs-daemon launchctl_domain daemon_argument
  local plist="$HOME/Library/LaunchAgents/$label.plist"
  if [[ -x /Applications/Emacs.app/Contents/MacOS/Emacs ]]; then
    emacs_executable=/Applications/Emacs.app/Contents/MacOS/Emacs
  else
    emacs_executable="$(command -v emacs)" || {
      echo "emacs executable not found."
      return 1
    }
  fi

  launchctl_domain="gui/$(id -u)"
  if [[ -f "$plist" ]]; then
    daemon_argument="$(plutil -extract ProgramArguments.1 raw -o - "$plist" 2> /dev/null)"
    if [[ "$daemon_argument" == --fg-daemon ]]; then
      echo "Emacs daemon LaunchAgent already exists: $plist (skip)"
      return 0
    fi
    if [[ "$daemon_argument" != --daemon ]]; then
      echo "Unrecognized Emacs LaunchAgent left unchanged: $plist"
      return 0
    fi
    echo "Migrating Emacs LaunchAgent to a foreground daemon: $plist"
    launchctl bootout "$launchctl_domain" "$plist" > /dev/null 2>&1 || true
  fi

  mkdir -p "${plist:h}" "$HOME/Library/Logs"
  plutil -create xml1 "$plist"
  plutil -insert Label -string "$label" "$plist"
  plutil -insert ProgramArguments -array "$plist"
  plutil -insert ProgramArguments.0 -string "$emacs_executable" "$plist"
  plutil -insert ProgramArguments.1 -string --fg-daemon "$plist"
  plutil -insert RunAtLoad -bool true "$plist"
  plutil -insert KeepAlive -bool false "$plist"
  plutil -insert EnvironmentVariables -dictionary "$plist"
  plutil -insert EnvironmentVariables.DOOMDIR -string "$HOME/.config/doom" "$plist"
  plutil -insert EnvironmentVariables.PATH -string "/opt/homebrew/opt/ccache/libexec:$PATH:$HOME/.config/emacs/bin" "$plist"
  plutil -insert StandardOutPath -string "$HOME/Library/Logs/$label.out.log" "$plist"
  plutil -insert StandardErrorPath -string "$HOME/Library/Logs/$label.err.log" "$plist"

  launchctl bootout "$launchctl_domain" "$plist" > /dev/null 2>&1 || true
  launchctl bootstrap "$launchctl_domain" "$plist"
  launchctl enable "$launchctl_domain/$label"
}

install_doom_icon_fonts() {
  local emacsclient_executable font_file
  if [[ "$OSTYPE" == darwin* ]]; then
    font_file="$HOME/Library/Fonts/NFM.ttf"
    emacsclient_executable=/Applications/Emacs.app/Contents/MacOS/bin/emacsclient
  else
    font_file="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NFM.ttf"
    emacsclient_executable="$(command -v emacsclient)" || {
      echo "emacsclient executable not found."
      return 1
    }
  fi

  if [[ -f "$font_file" ]]; then
    echo "Doom icon font already exists: $font_file (skip)"
    return 0
  fi

  until "$emacsclient_executable" --eval t > /dev/null 2>&1; do
    sleep 0.1
  done
  "$emacsclient_executable" --eval '(nerd-icons-install-fonts t)'
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
  install_doom_icon_fonts
}

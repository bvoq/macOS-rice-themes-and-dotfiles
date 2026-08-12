e() {
  if ! emacsclient --eval t > /dev/null 2>&1; then
    if [[ "$OSTYPE" == darwin* ]]; then
      local domain="gui/$(id -u)"
      local label="emacs-daemon"
      local plist="$HOME/Library/LaunchAgents/$label.plist"

      if ! launchctl kickstart "$domain/$label" > /dev/null 2>&1; then
        [[ -f "$plist" ]] || {
          echo "Emacs daemon LaunchAgent not found: $plist" >&2
          return 1
        }
        launchctl bootstrap "$domain" "$plist" > /dev/null 2>&1 || return 1
        launchctl kickstart "$domain/$label" > /dev/null 2>&1 || return 1
      fi
    else
      emacs --daemon || return 1
    fi

    local attempt
    for attempt in {1..50}; do
      emacsclient --eval t > /dev/null 2>&1 && break
      sleep 0.1
    done
    emacsclient --eval t > /dev/null 2>&1 || {
      echo "Emacs daemon did not become ready." >&2
      return 1
    }
  fi

  emacsclient --create-frame --no-wait "$@"
}
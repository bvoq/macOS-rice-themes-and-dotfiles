e() {
  if [[ "$OSTYPE" != darwin* ]]; then
    emacsclient --alternate-editor='' --create-frame --no-wait "$@"
    return
  fi

  local emacsclient_executable=/Applications/Emacs.app/Contents/MacOS/bin/emacsclient
  local server_socket="/private/tmp/emacs$(id -u)/server"
  [[ -x "$emacsclient_executable" ]] || emacsclient_executable="$(command -v emacsclient)"

  local attempt daemon_ready=false
  for attempt in {1..20}; do
    if "$emacsclient_executable" --socket-name="$server_socket" --eval t > /dev/null 2>&1; then
      daemon_ready=true
      break
    fi
    sleep 0.1
  done

  if [[ "$daemon_ready" == false ]]; then
    local domain="gui/$(id -u)"
    local label=emacs-daemon
    local plist="$HOME/Library/LaunchAgents/$label.plist"
    local log_file line_count previous_line
    local -a daemon_logs=(
      "$HOME/Library/Logs/$label.out.log"
      "$HOME/Library/Logs/$label.err.log"
    )
    local -A log_line_counts

    [[ -f "$plist" ]] || {
      echo "Emacs daemon LaunchAgent not found: $plist" >&2
      return 1
    }

    mkdir -p "$HOME/Library/Logs"
    touch "${daemon_logs[@]}"
    for log_file in "${daemon_logs[@]}"; do
      log_line_counts[$log_file]="$(wc -l < "$log_file")"
    done

    echo "Emacs did not respond within 2 seconds; restarting its LaunchAgent."
    if ! launchctl kickstart -k "$domain/$label" > /dev/null 2>&1; then
      launchctl bootstrap "$domain" "$plist" > /dev/null 2>&1 || return 1
      launchctl kickstart -k "$domain/$label" > /dev/null 2>&1 || return 1
    fi

    echo "Waiting for the Emacs daemon; press Ctrl-C to stop."
  until "$emacsclient_executable" --socket-name="$server_socket" --eval t > /dev/null 2>&1; do
      for log_file in "${daemon_logs[@]}"; do
        line_count="$(wc -l < "$log_file")"
        previous_line="${log_line_counts[$log_file]:-0}"
        if (( line_count < previous_line )); then
          previous_line=0
        fi
        if (( line_count > previous_line )); then
          echo "==> $log_file <=="
          sed -n "$(( previous_line + 1 )),${line_count}p" "$log_file"
          log_line_counts[$log_file]="$line_count"
        fi
      done
      sleep 0.1
    done
  fi

  "$emacsclient_executable" --socket-name="$server_socket" --create-frame --no-wait "$@" || return 1
  open -a Emacs
}
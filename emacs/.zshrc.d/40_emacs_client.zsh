e() {
  if [[ "$OSTYPE" != darwin* ]]; then
    emacsclient --alternate-editor='' --create-frame --no-wait "$@"
    return
  fi

  local emacsclient_executable=/Applications/Emacs.app/Contents/MacOS/bin/emacsclient
  local server_socket="/private/tmp/emacs$(id -u)/server"
  [[ -x "$emacsclient_executable" ]] || emacsclient_executable="$(command -v emacsclient)"
  local domain="gui/$(id -u)"
  local label=emacs-daemon
  local plist="$HOME/Library/LaunchAgents/$label.plist"
  local daemon_pid failure_reason log_file line_count previous_line sampled_state
  local restart_count=0
  local -a daemon_logs=(
    "$HOME/Library/Logs/$label.out.log"
    "$HOME/Library/Logs/$label.err.log"
  )
  local -A log_line_counts

  [[ -f "$plist" ]] || {
    echo "Emacs daemon LaunchAgent not found: $plist" >&2
    return 1
  }
  command -v gtimeout > /dev/null || {
    echo "gtimeout not found; install coreutils." >&2
    return 1
  }

  mkdir -p "$HOME/Library/Logs"
  touch "${daemon_logs[@]}"
  for log_file in "${daemon_logs[@]}"; do
    log_line_counts[$log_file]="$(wc -l < "$log_file")"
  done

  while true; do
    failure_reason=""
    if gtimeout 2 "$emacsclient_executable" \
      --socket-name="$server_socket" --eval t > /dev/null 2>&1; then
      daemon_pid="$(launchctl print "$domain/$label" 2> /dev/null |
        awk '/^[[:space:]]*pid =/{print $3; exit}')"
      sampled_state=""
      if [[ -n "$daemon_pid" ]]; then
        sampled_state="$(sample "$daemon_pid" 0.05 1 2> /dev/null |
          grep -E -m 1 'read.multiple.choice')"
      fi

      if [[ -n "$sampled_state" ]]; then
        failure_reason="Emacs responds but is blocked on hidden interactive input."
      elif gtimeout 5 "$emacsclient_executable" \
        --socket-name="$server_socket" --create-frame --no-wait "$@"; then
        open -a Emacs
        return 0
      else
        failure_reason="Emacs accepted connections but did not create a frame within 5 seconds."
      fi
    else
      failure_reason="Emacs did not respond within 2 seconds."
    fi

    if ((restart_count >= 1)); then
      echo "$failure_reason" >&2
      return 1
    fi

    echo "$failure_reason"
    echo "LaunchAgent state:"
    launchctl print "$domain/$label" 2> /dev/null |
      grep -E '^[[:space:]]*(state|pid|last exit code) =' |
      head -n 3

    daemon_pid="$(launchctl print "$domain/$label" 2> /dev/null |
      awk '/^[[:space:]]*pid =/{print $3; exit}')"
    if [[ -n "$daemon_pid" ]]; then
      ps -p "$daemon_pid" -o pid,ppid,etime,stat,command
      sampled_state="$(sample "$daemon_pid" 1 1 2> /dev/null |
        grep -E -m 1 'read.multiple.choice|read.from.minibuffer|read_filtered_event|read_char')"
      if [[ -n "$sampled_state" ]]; then
        echo "Emacs appears to be waiting for interactive input:"
        echo "${sampled_state##+([[:space:]])}"
      fi
    fi

    for log_file in "${daemon_logs[@]}"; do
      echo "==> $log_file (last 10 lines) <=="
      tail -n 10 "$log_file"
    done

    if ! read -q "reply?Hard restart the Emacs daemon? [y/N] "; then
      echo
      echo "Emacs daemon left running."
      return 1
    fi
    echo

    if ! launchctl kickstart -k "$domain/$label" > /dev/null 2>&1; then
      launchctl bootstrap "$domain" "$plist" > /dev/null 2>&1 || return 1
      launchctl kickstart -k "$domain/$label" > /dev/null 2>&1 || return 1
    fi
    restart_count=$((restart_count + 1))

    echo "Waiting for the Emacs daemon; press Ctrl-C to stop."
    until gtimeout 1 "$emacsclient_executable" \
      --socket-name="$server_socket" --eval t > /dev/null 2>&1; do
      for log_file in "${daemon_logs[@]}"; do
        line_count="$(wc -l < "$log_file")"
        previous_line="${log_line_counts[$log_file]:-0}"
        if ((line_count < previous_line)); then
          previous_line=0
        fi
        if ((line_count > previous_line)); then
          echo "==> $log_file <=="
          sed -n "$((previous_line + 1)),${line_count}p" "$log_file"
          log_line_counts[$log_file]="$line_count"
        fi
      done
    done
  done
}

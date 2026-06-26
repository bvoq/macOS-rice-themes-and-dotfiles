add_vscode_bookmark () {
  local file_line="$1"
  local label="$2"
  code --goto "$file_line"
  sleep 0.5
  osascript -e 'tell application "System Events" to keystroke "p" using {command down, shift down}'
  sleep 0.4
  osascript -e 'tell application "System Events" to keystroke "Bookmarks: Toggle Labeled"'
  sleep 0.1
  osascript -e 'tell application "System Events" to key code 36'
  sleep 0.4
  osascript -e "tell application \"System Events\" to keystroke \"$label\""
  sleep 0.1
  osascript -e 'tell application "System Events" to key code 36'
}

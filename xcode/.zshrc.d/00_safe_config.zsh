add_xcode_bookmark() {
  local file_line="$1"
  local label="$2"
  local file="${file_line%:*}"
  local line="${file_line##*:}"

  xed --line "$line" "$file"
  osascript -e "tell application \"Xcode\" to activate" \
    -e "tell application \"Xcode\" to open \"$file\"" \
    -e 'delay 1' \
    -e 'tell application "System Events" to keystroke "^" using {control down, option down, command down}' \
    -e 'delay 0.3' \
    -e "tell application \"System Events\" to keystroke \"$label\"" \
    -e 'tell application "System Events" to key code 36'

  echo "Added Xcode bookmark: $label at $file:$line"
  echo "Used keystroke '^' with Control+Option+Command"
}

# Open xcode project properly using just x.
function x() {
  dir="${1:-.}"
  matches=("xcworkspace" "xcodeproj" "playground")
  for ext in "${matches[@]}"; do
    for file in "$dir"/*."$ext"(N); do
      if [[ -e "$file" ]]; then
        xed "$file"
        return
      fi
    done
  done
  echo "No .xcworkspace, .xcodeproj, or .playground found in '$dir'."
}
export -f x > /dev/null

# Open ios simulator
alias ios="open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"

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
#alias x='matches=("xcworkspace" "xcodeproj" "playground"); for i in "${matches[@]}"; do if [ -d *.${i} ]; then open -a Xcode *.${i}; break; fi; done'

alias dca='dart run dart_code_linter:metrics analyze lib --fatal-style --fatal-performance --fatal-warnings;dart run dart_code_linter:metrics check-unused-files lib --fatal-unused'

simulatordata() { cd ~/Library/Developer/CoreSimulator/Devices/"${1}"/data/Containers/Data/Application ; ls -lt ; pwd}

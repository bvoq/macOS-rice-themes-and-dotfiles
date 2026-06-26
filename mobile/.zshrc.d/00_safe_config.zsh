# Open ios simulator
alias ios="open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"

alias dca='dart run dart_code_linter:metrics analyze lib --fatal-style --fatal-performance --fatal-warnings;dart run dart_code_linter:metrics check-unused-files lib --fatal-unused'

simulatordata() { cd ~/Library/Developer/CoreSimulator/Devices/"${1}"/data/Containers/Data/Application ; ls -lt ; pwd}

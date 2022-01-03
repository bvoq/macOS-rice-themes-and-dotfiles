#!/bin/zsh

# ==============
# macOS specific 
# ==============

# open command line tab in same location
alias hopen='open -a /Applications/Utilities/Terminal.app .'

# =======================
# specific for my machine
# =======================
# external hard drive not mounting https://apple.stackexchange.com/questions/268998/external-hard-drive-wont-mount

# look for virtual keycode macos for a chart
brokenkeys() {
    hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000029,"HIDKeyboardModifierMappingDst":0x70000002D},{"HIDKeyboardModifierMappingSrc":0x700000027,"HIDKeyboardModifierMappingDst":0x70000000B}]}'
}
nobrokenkeys() {
    hidutil property --set '{"UserKeyMapping":[]}'
}

export -f brokenkeys
export -f nobrokenkeys

# some useful flags
# set -x # activate debugging
# set +x # disable debugging
# set -o verbose # simply showing the commands
# set +o verbose
# set -e # exit on error, useful for debugging but add || exit 1
# set +e

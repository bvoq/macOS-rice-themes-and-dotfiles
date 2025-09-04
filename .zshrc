#!/bin/zsh

####################
# General zsh uses #
####################
source ~/.zshfunctions

# make sure utf-8 is used
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export MANPATH="/usr/local/man:$MANPATH"
export ARCHFLAGS="-arch $(uname -m)"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# store all cd directory pushes
setopt AUTO_PUSHD

# make sure that enter key works: https://askubuntu.com/questions/441744/pressing-enter-produces-m-instead-of-a-newline
stty sane

################
# Source stuff #
################

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init - zsh)"

###################
# Oh-my-zsh / NVM #
###################

CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1
export ZSH="$HOME/.oh-my-zsh"
chmod -R go-w "$ZSH"
#ZSH_THEME="agnoster"
DISABLE_AUTO_TITLE="true"
#ENABLE_CORRECTION="true"
#Uncomment below to stop marking untracked files as dirty for speedup.
DISABLE_UNTRACKED_FILES_DIRTY="true"
zstyle ':omz:update' mode reminder
plugins=(brew git pyautoenv zsh-nvm)
zstyle ':omz:update' mode reminder
source $ZSH/oh-my-zsh.sh
nvm use node --silent

###########
# Aliases #
###########

# Enable aliases to be sudo’ed
alias sudo='sudo '

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias gitroot="cd \$(git rev-parse --show-toplevel)"

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
    export LS_COLORS='no=00:fi=00:di=01;31:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
else # macOS `ls`
    colorflag="-G"
    export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
fi
# Always use color output for `ls`
alias ls="command ls ${colorflag}"
# List all files colorized in long format
alias l="ls -lF ${colorflag}"
# List all files colorized in long format, excluding . and ..
alias la="ls -lAF ${colorflag}"
# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

alias which="which -a"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Always enable colored `grep` output by default
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"


# Merge PDF files, preserving hyperlinks
# Usage: `mergepdf input{1,2,3}.pdf`
alias mergepdf='gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=_merged.pdf'
alias mergepdf2='pdfjoin --rotateoversize false'

alias grabsite='wget -r -np --wait=1 -k --execute="robots = off" --mirror --random-wait --user-agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0"'

# make sure to use " around url when using ymp3, works for playlists and single videos.
alias ymp3='yt-dlp -x --audio-format mp3 --add-metadata --embed-thumbnail --cookies-from-browser chrome'
alias ymp4='yt-dlp -fmp4 --write-sub --write-auto-sub --sub-lang "en.*" --cookies-from-browser chrome'

alias sqloptimize='sqlite3 "$1" "VACUUM;" && sqlite3 "$1" "REINDEX;"'
alias gitzip="git archive HEAD -o ${PWD##*/}.zip"

# find large git files in repo history.
alias largegit="git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print substr($""0,6)}' | sort --numeric-sort --key=2 | gnumfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest"
# then remove using
# git obliterate ./path/to/large/file
# rm -Rf .git/refs/original
# git gc --aggressive --prune=now

# =============
# AI
# =============
alias localai="ollama run gemma3n:e4b 'You are run in a unix zsh CLI, stay concise.'"
alias claude="~/.local/bin/claude"
CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1


# ==============
# DevOps
# ==============
# make sure to enable zsh-completions first
#source <(kubectl completion zsh)  # setup autocomplete in zsh into the current shell
alias k=kubectl
alias kns='kubectl config set-context --current --namespace '
alias kall='kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found' # add -n <namespace>
export EDITOR=vim # enable `k edit` on macOS
# export KUBE_EDITOR=vim # alternatively
if command -v compdef > /dev/null; then
  compdef _kubectl k
fi
# useful devops commands
# shell into container:
# kubectl exec -it <pod> [-c <container>] -- sh
# kubectl debug -it debugcontainer --image=busybox:1.28 --target=<pod>
# kubectl debug myapp -it --image=debugcontainerimage --share-processes --copy-to=myapp-debug

# stop and delete docker containers by their image id
dsi() { docker stop $(docker ps -a | awk -v i="^$1.*" '{if($2~i){print$1}}'); }
drmi() { docker rm $(dsi $1  | tr '\n' ' '); }

# ==============
# macOS specific 
# ==============

# enable zsh-completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$(brew --prefix)/share/zsh-completions:$ZSH/completions:$FPATH
  autoload -Uz compinit
  compinit -u 2>/dev/null || compinit -C
fi
if type fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi
if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Search for files:
alias rgd='rg --hidden --files --sort-files . 2> /dev/null | xargs -0 dirname | uniq | rg'
alias rgf='rg --hidden --files --sort-files . 2> /dev/null | rg'
rgall() {
  rg --files | rg "$1" ; rg --hidden -uu "$1"
}
rgvim() { # use :cn and :cp to navigate afterwards, :cl to list
  vim -c 'set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --fixed-strings' \
      -c "grep ${1} ." .
}
export -f rgall > /dev/null
rgdot() {
  local eg_was_on=1 gd_was_on=1
  is_on extended_glob || eg_was_on=0
  is_on glob_dots     || gd_was_on=0
  setopt extended_glob glob_dots
  rg "$1" .*~.zsh_history(.)
  (( eg_was_on == 0 )) && unsetopt extended_glob
  (( gd_was_on == 0 )) && unsetopt glob_dots
}
rgempty() {
    # empty directories
    find . -type d -empty -print
    # grep is slightly faster with whitespaces.
    find . -type f ! -exec grep -q '[^[:space:]]' {} \; -print
    # alternatively: find . -type f ! -exec rg -q '[^[:space:]]' {} \; -print
}
export -f rgempty > /dev/null


# Use as follows: rgfzf '*_bloc.dart' to recursively find all files ending with _bloc.dart and then use fzf to find a string.
rgfzf() {
  rg --no-heading --hidden --sort-files --line-number --color=always --glob "$1" "" | fzf --ansi --nth=3..
}
export -f rgfzf > /dev/null


# Fast exact text search using Spotlight
rgspotlight() {
  echo "'""kMDItemTextContent = "'"'"$1"'"'"'"
  mdfind "kMDItemTextContent = "'"'"$1"'"'
}
export -f rgspotlight > /dev/null

# for those old people who still use bash? bash completion support
# [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion


# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"

# JavaScriptCore REPL
jscbin="/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc";
[ -e "${jscbin}" ] && alias jsc="${jscbin}";
unset jscbin;

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

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


# Defines: GET, HEAD, POST, PUT, DELETE, TRACE, OPTIONS:
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "${method}"="lwp-request -m '${method}'"
done

#NGET, NHEAD, etc. for uncertified requests and most likely headers.
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "N${method}"="PERL_LWP_SSL_VERIFY_HOSTNAME=0 lwp-request -m '${method}' -H 'Content-type: application/json' -H 'Accept: application/json'"
done


# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# open new window in same location as current terminal.
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    alias hopen='open . -a Terminal.app'
elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    alias hopen='open . -a iTerm'
    source ~/.iterm2_shell_integration.zsh
fi

# iTerm2 or other terminals, make sure that the last two folders of PWD is shown in the tab bar.
# if [ $ITERM_SESSION_ID ]; then
# precmd() {
#   echo -ne "\033]0;${PWD#*${PWD%*/*/*}}\007"
# }
# fi

# play playlist by added by date:
alias mplaylist='mdfind -onlyin . "kMDItemContentTypeTree == \"public.audio\"" | while read -r file; do echo "$(mdls -name kMDItemDateAdded -raw "$file") $file"; done | sort | cut -d" " -f4- | xargs -I {} mpg123 "{}"'
alias vplaylist='mdfind -onlyin . "kMDItemContentTypeTree == \"public.movie\"" | while read -r file; do echo "$(mdls -name kMDItemDateAdded -raw "$file") $file"; done | sort | cut -d" " -f4- > playlist.m3u && open -a VLC playlist.m3u'



# ========
# Homebrew
# ========

alias brewleaves='brew deps --installed | grep -E "$(paste -sd "|" <(brew leaves))"'

# takes a long while but sorts packages by their size and states their leaf dependencies.
brewmem() {
    brew list --formula | xargs -n1 -P8 -I {} sh -c "brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'" | sort -h -r -k2 - | xargs -L1 bash -c 'echo $0 $1 Leaves: $(brew uses --installed --recursive $0 | grep -E "( |^)$(paste -sd " " <(brew leaves) | sed "s/ /( |$)|( |^)/g")( |$)")'
}
export -f brewmem > /dev/null

# List packages and sort them by memory, may take a while: https://stackoverflow.com/questions/40065188/get-size-of-each-installed-formula-in-homebrew
alias brewmemsimple="brew list --formula | xargs -n1 -P8 -I {} sh -c \"brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'\" | sort -h -r -k2 - | column -t"

# useful:
# brew uses --installed --recursive <package>
# brew deps --installed --tree <package>

# Usage: pdfjoings merged.pdf file1.pdf file2.pdf ... fileN.pdf
pdfjoings () { 
  gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="$1" "${@:2}"
}

# =======================
# specific for my machine
# =======================

alias rclone="rclone -v -P"
alias rstream="rclone serve http safe: --addr localhost:8080 --vfs-cache-mode full"
# mkdir -p ~/wasabi-kdkdk
# rclone mount -q wasabi-kdkdk:kdkdk/ ~/wasabi-kdkdk/ &

alias dca='dart run dart_code_linter:metrics analyze lib --fatal-style --fatal-performance --fatal-warnings;dart run dart_code_linter:metrics check-unused-files lib --fatal-unused'

# fix my keys on macOS
# look for usage id key macos:
# https://developer.apple.com/library/archive/technotes/tn2450/_index.html
fixkeys() {
    sudo hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000033,"HIDKeyboardModifierMappingDst":0x700000011},{"HIDKeyboardModifierMappingSrc":0x700000034,"HIDKeyboardModifierMappingDst":0x700000005}]}'
}
nofixkeys() {
    sudo hidutil property --set '{"UserKeyMapping":[]}'
}
export -f fixkeys > /dev/null
export -f nofixkeys > /dev/null


# Add secrets and auth from private repo
# export GOOGLE_APPLICATION_CREDENTIALS="~/private/keys/mooddex-key.json"

# bb & azure auth, private access token
bbauth() { pbcopy < ~/private/keys/bbauth.txt }
azauth() { pbcopy < ~/private/keys/azureauth.txt }

totp() { oathtool --totp -b $(<~/".totp_${1:-zuhlke}") | pbcopy; }
# add more (umask 0077;pbpaste > ~/.totp_)
# call otherprovider using totp otherprovider for e.g.

simulatordata() { cd ~/Library/Developer/CoreSimulator/Devices/"${1}"/data/Containers/Data/Application ; ls -lt ; pwd}

# external hard drive not mounting https://apple.stackexchange.com/questions/268998/external-hard-drive-wont-mount
# ps aux | grep fsck
# sudo pkill -f fsck

### How to disable the SD card drive on macOS:
# mdutil -i off /Volumes/yourUSBstick
# cd /Volumes/yourUSBstick
# rm -rf .{,_.}{fseventsd,Spotlight-V*,Trashes}
# mkdir .fseventsd
# touch .fseventsd/no_log .metadata_never_index .Trashes
# cd -

# References:
# some useful flags
# set -x # activate debugging
# set +x # disable debugging
# set -o verbose # simply showing the commands
# set +o verbose
# set -e # exit on error, useful for debugging but add || exit 1
# set +e

# useful bash expansions
# SOURCEDIR=${SOURCEDIR::-1%/*} # remove last character and then remove path
# SOURCEDIR=${SOURCEDIR%/*}  # get dirname
# SOURCEDIR=$(dirname $SOURCEDIR)  # get dirname
# SOURCEDIR=${${${SOURCEDIR::-1}%/*}%/*} # remove last char (in case it is a / and go up two folders))
# SOURCEDIR=${SOURCEDIR##*/} # get last part of path
# SOURCEDIR=${SOURCEDIR#*/}  # get first part of path
# SOURCEDIR=${${SOURCEDIR%/*}%/*} # go up two folders

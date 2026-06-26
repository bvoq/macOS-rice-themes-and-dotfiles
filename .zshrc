#!/bin/zsh

######################
# 00_safe_config.zsh #
######################
# aliases, functions, helper sources, variables safe to define even in limited/dumb contexts

source ~/.unofunctions.zsh
source ~/.zshfunctions

# Enable aliases to be sudo’ed
alias sudo='sudo '

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
    export LS_COLORS='no=00:fi=00:di=01;31:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
else # macOS `ls`
    colorflag="-G"
    export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
fi
# List all files colorized in long format
alias l="eza"
# List all files colorized in long format, excluding . and ..
alias la="ls -lAF ${colorflag}"
# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

alias which="which -a"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

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

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Find and interactively delete duplicate files
alias dup='fdupes -d'

# Defines: GET, HEAD, POST, PUT, DELETE, TRACE, OPTIONS:
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "${method}"="lwp-request -m '${method}'"
done

#NGET, NHEAD, etc. for uncertified requests and most likely headers.
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "N${method}"="PERL_LWP_SSL_VERIFY_HOSTNAME=0 lwp-request -m '${method}' -H 'Content-type: application/json' -H 'Accept: application/json'"
done

# Usage: pdfjoings merged.pdf file1.pdf file2.pdf ... fileN.pdf
pdfjoings () {
  gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="$1" "${@:2}"
}

################
# 10_guard.zsh #
################
# return early for non-interactive/dumb/non-tty cases; terminal repair like stty sane

[[ -o interactive ]] || return 0
[[ -t 0 ]] || return 0
[[ "$TERM" == dumb ]] && return 0

# make sure that enter key works: https://askubuntu.com/questions/441744/pressing-enter-produces-m-instead-of-a-newline
stty sane

#######################
# 20_ishell_config.zsh #
#######################
# interactive shell behavior: setopt, bindkey basics, history options

# store all cd directory pushes
setopt AUTO_PUSHD

[ -f ~/.zshrc_private ] && source ~/.zshrc_private

export PATH="$(gem env gemdir)/bin:$PATH"

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

##############################
# 30_pre_compinit_setup.zsh #
##############################
# fpath/FPATH additions, completion zstyles, plugins that only provide completion sources

for zshrc_file in "${ZDOTDIR:-$HOME}"/.zshrc.d/30_*.zsh(N); do
  source "$zshrc_file"
done
unset zshrc_file
FPATH=$HOME/.zsh/completions:$FPATH

# for those old people who still use bash? bash completion support
# [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

##################
# 40_compinit.zsh #
##################
# autoload -Uz compinit
# compinit

autoload -Uz compinit
compinit -u 2>/dev/null || compinit -C

#######################
# 50_ishell_setup.zsh #
#######################
# tool initialization after shell/completion base is ready:
# fzf, zoxide, direnv, starship, compdef

# shell integration for vscode for better copilot support
# https://code.visualstudio.com/docs/terminal/shell-integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if type fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi

command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell zsh)"

if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
# command -v rbenv >/dev/null 2>&1 && ( eval "$(rbenv init - zsh)" || true )

# iTerm2 or other terminals, make sure that the last two folders of PWD is shownh in the tab bar.
# if [ $ITERM_SESSION_ID ]; then
# precmd() {
#   echo -ne "\033]0;${PWD#*${PWD%*/*/*}}\007"
# }
# fi

# Package shell fragments
for zshrc_file in "${ZDOTDIR:-$HOME}"/.zshrc.d/*.zsh(N); do
  [[ "${zshrc_file:t}" == 30_* ]] && continue
  source "$zshrc_file"
done
unset zshrc_file

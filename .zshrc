#!/bin/zsh

######################
# 00_safe_config.zsh #
######################
# aliases, functions, helper sources, variables safe to define even in limited/dumb contexts

source ~/.zshfunctions

# Enable aliases to be sudo’ed
alias sudo='sudo '

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

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

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

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

# Package shell fragments
for zshrc_file in "${ZDOTDIR:-$HOME}"/.zshrc.d/*.zsh(N); do
  [[ "${zshrc_file:t}" == 30_* ]] && continue
  source "$zshrc_file"
done
unset zshrc_file

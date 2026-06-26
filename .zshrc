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
alias la="ls -lAF"
# List only directories
alias lsd="ls -lF"

alias which="which -a"

# Always enable colored `grep` output by default
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

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

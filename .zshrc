#!/bin/zsh

######################
# 00_safe_config.zsh #
######################
# aliases, functions, helper sources, variables safe to define even in limited/dumb contexts

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

#  Still using bash? bash completion support:
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

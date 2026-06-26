#!/bin/zsh

# Source every shell fragment in ~/.zshrc.d/ in lexical order. Phases are encoded
# in the numeric filename prefix (00 safe-config, 10 guard, 20 pre-compinit,
# 30 compinit, 40 ishell-setup). A fragment may raise UNODOT_STOP to halt early —
# the guard uses this to skip the rest in non-interactive/dumb shells.
for zshrc_file in "${ZDOTDIR:-$HOME}"/.zshrc.d/*.zsh(N); do
  source "$zshrc_file"
  (( ${UNODOT_STOP:-0} )) && break
done
unset zshrc_file UNODOT_STOP

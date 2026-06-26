#!/bin/zsh

# General
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export ARCHFLAGS="-arch $(uname -m)"

# Pager settings for less
export PAGER='less'
export LESS='-R'

for zshenv_file in "${ZDOTDIR:-$HOME}"/.zshenv.d/.zshenv_*(N); do
  source "$zshenv_file"
done
unset zshenv_file

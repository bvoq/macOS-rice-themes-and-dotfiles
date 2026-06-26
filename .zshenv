#!/bin/zsh

for zshenv_file in "${ZDOTDIR:-$HOME}"/.zshenv.d/.zshenv_*(N); do
  source "$zshenv_file"
done
unset zshenv_file

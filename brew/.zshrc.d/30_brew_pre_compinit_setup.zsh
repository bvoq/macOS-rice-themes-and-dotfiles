if type brew &>/dev/null; then
  BREW_PREFIX=$(brew --prefix)
  FPATH=$BREW_PREFIX/share/zsh/site-functions:$BREW_PREFIX/share/zsh-completions:$FPATH
fi

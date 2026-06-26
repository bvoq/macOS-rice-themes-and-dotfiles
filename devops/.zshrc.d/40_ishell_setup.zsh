# make sure to enable zsh-completions first
#source <(kubectl completion zsh)  # setup autocomplete in zsh into the current shell
if command -v compdef > /dev/null; then
  compdef _kubectl k
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if type fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi

command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell zsh)"

if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

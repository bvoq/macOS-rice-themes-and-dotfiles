DISABLE_AUTO_TITLE="true"
#ENABLE_CORRECTION="true"

if type brew &>/dev/null; then
  source "$(brew --prefix)/share/antidote/antidote.zsh"
  antidote load
fi

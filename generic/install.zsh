phase_1_admin_installs() {
  install_brewfile generic/Brewfile.crossplatform
  install_brewfile generic/Brewfile.macos
}

phase_2_user_installs() {
  [ ! -d "${ZDOTDIR:-$HOME}/.antidote" ] && git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
  tldr --update
  curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
}

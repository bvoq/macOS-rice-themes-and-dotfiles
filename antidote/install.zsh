phase_2_user_installs() {
  [ ! -d "${ZDOTDIR:-$HOME}/.antidote" ] && git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
}

phase_3_dotfiles() {
  link_dotfile "antidote/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
  link_dotfile "antidote/.zshrc.d/50_antidote_setup.zsh" "$HOME/.zshrc.d/50_antidote_setup.zsh"
}

phase_2_user_installs() {
  if [[ ! -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
  fi
}

phase_3_dotfiles() {
  link_dotfile "antidote/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
  link_dotfile "antidote/.zshrc.d/40_ishell_setup.zsh" "$HOME/.zshrc.d/40_ishell_setup_antidote.zsh"
}

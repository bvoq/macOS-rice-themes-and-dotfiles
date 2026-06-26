phase_3_dotfiles() {
  link_dotfile "brew/.zshrc.d/00_brew_safe_config.zsh" "$HOME/.zshrc.d/00_brew_safe_config.zsh"
  link_dotfile "brew/.zshrc.d/30_brew_pre_compinit_setup.zsh" "$HOME/.zshrc.d/30_brew_pre_compinit_setup.zsh"
}

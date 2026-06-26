phase_3_dotfiles() {
  link_dotfile "brew/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_brew.zsh"
  link_dotfile "brew/.zshrc.d/20_pre_compinit.zsh" "$HOME/.zshrc.d/20_pre_compinit_brew.zsh"
}

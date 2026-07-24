phase_1_admin_installs() {
  install_brewfile quarto/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "quarto/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_quarto.zsh"
}
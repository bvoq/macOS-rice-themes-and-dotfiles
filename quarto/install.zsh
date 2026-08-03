phase_1_admin_installs() {
  install_brewfile quarto/Brewfile
}

phase_2_user_installs() {
  quarto install tinytex
  # If you're running this on a server and don't have Chrome you might need to install: 
  # quarto install chrome-headless-shell
}

phase_3_dotfiles() {
  link_dotfile "quarto/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_quarto.zsh"
}
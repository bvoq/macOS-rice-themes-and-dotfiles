phase_1_admin_installs() {
  install_brewfile ripgrep/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "ripgrep/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_ripgrep.zsh"
}

phase_1_admin_installs() {
  install_brewfile ssdeep/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "ssdeep/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_ssdeep.zsh"
}

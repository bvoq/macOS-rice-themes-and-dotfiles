phase_1_admin_installs() {
  install_brewfile rclone/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "rclone/bsync.sh" "$HOME/.config/rclone/bsync.sh"
  link_dotfile "rclone/.zshrc.d/00_rclone_safe_config.zsh" "$HOME/.zshrc.d/00_rclone_safe_config.zsh"
}
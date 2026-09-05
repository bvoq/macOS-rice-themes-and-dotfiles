phase_1_admin_installs() {
  install_brewfile copilot/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "copilot/settings.json" "$HOME/.copilot/settings.json"
  link_dotfile "copilot/.zshrc" "$HOME/.zshrc.d/00_safe_config_copilot.zsh"
}

phase_4_post_dotfiles() {
  command -v code > /dev/null 2>&1 || return 0
}

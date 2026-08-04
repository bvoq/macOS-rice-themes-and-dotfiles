phase_1_admin_installs() {
  install_brewfile copilot/Brewfile
}

phase_4_post_dotfiles() {
  command -v code > /dev/null 2>&1 || return 0
  code --install-extension GitHub.copilot
}
phase_1_admin_installs() {
  install_brewfile tmux/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "tmux/.tmux.conf" "$HOME/.tmux.conf"
}

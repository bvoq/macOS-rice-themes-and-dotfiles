phase_1_admin_installs() {
  install_brewfile zsh/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "zsh/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
  link_dotfile "zsh/.zshrc.d/40_ishell_setup.zsh" "$HOME/.zshrc.d/40_ishell_setup_zsh.zsh"
}

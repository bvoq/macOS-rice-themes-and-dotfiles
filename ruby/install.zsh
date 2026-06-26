phase_1_admin_installs() {
  install_brewfile ruby/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "ruby/.zshenv" "$HOME/.zshenv.d/.zshenv_ruby"
  link_dotfile "ruby/.zshrc.d/40_ishell_setup.zsh" "$HOME/.zshrc.d/40_ishell_setup_ruby.zsh"
}

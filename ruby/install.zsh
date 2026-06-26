phase_1_admin_installs() {
  install_brewfile ruby/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "ruby/.zshenv" "$HOME/.zshenv.d/.zshenv_ruby"
  link_dotfile "ruby/.zshrc.d/50_ruby_ishell_setup.zsh" "$HOME/.zshrc.d/50_ruby_ishell_setup.zsh"
}

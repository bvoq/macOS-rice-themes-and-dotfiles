phase_1_admin_installs() {
  install_brewfile starship/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "starship/starship.toml" "$HOME/.config/starship.toml"
  link_dotfile "starship/.zshrc.d/40_ishell_setup.zsh" "$HOME/.zshrc.d/40_ishell_setup_starship.zsh"
}

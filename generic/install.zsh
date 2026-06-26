phase_1_admin_installs() {
  install_brewfile generic/Brewfile.crossplatform
  install_brewfile generic/Brewfile.macos
}

phase_2_user_installs() {
  tldr --update
}

phase_3_dotfiles() {
  link_dotfile "generic/.zshenv" "$HOME/.zshenv.d/.zshenv_generic"
  link_dotfile "generic/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_generic.zsh"
  link_dotfile "generic/.zshrc.d/40_ishell_setup.zsh" "$HOME/.zshrc.d/40_ishell_setup_generic.zsh"
}

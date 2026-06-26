phase_1_admin_installs() {
  install_brewfile generic/Brewfile.crossplatform
  install_brewfile generic/Brewfile.macos
}

phase_2_user_installs() {
  tldr --update
  curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
}

phase_3_dotfiles() {
  link_dotfile "generic/.zshenv" "$HOME/.zshenv.d/.zshenv_generic"
}

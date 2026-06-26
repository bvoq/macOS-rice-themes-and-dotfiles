phase_3_dotfiles() {
  link_dotfile "core/.zshenv" "$HOME/.zshenv.d/.zshenv_core"
  link_dotfile "core/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config.zsh"
}

phase_3_dotfiles() {
  link_dotfile "git/.gitconfig" "$HOME/.gitconfig"
  link_dotfile "git/.gitignore_global" "$HOME/.gitignore_global"
  link_dotfile "git/.gitattributes_global" "$HOME/.gitattributes_global"
  link_dotfile "git/.zshrc.d/00_git_safe_config.zsh" "$HOME/.zshrc.d/00_git_safe_config.zsh"
}

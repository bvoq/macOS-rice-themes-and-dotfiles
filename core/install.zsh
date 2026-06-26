phase_3_dotfiles() {
  link_dotfile "core/.zshenv" "$HOME/.zshenv.d/.zshenv_core"
  link_dotfile "core/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_core.zsh"
  link_dotfile "core/.zshrc.d/10_guard.zsh" "$HOME/.zshrc.d/10_guard_core.zsh"
  link_dotfile "core/.zshrc.d/20_pre_compinit.zsh" "$HOME/.zshrc.d/20_pre_compinit_core.zsh"
  link_dotfile "core/.zshrc.d/30_compinit.zsh" "$HOME/.zshrc.d/30_compinit_core.zsh"
}

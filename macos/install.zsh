phase_3_dotfiles() {
  [[ $OSTYPE == 'darwin'* ]] || return 0
  link_dotfile "macos/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_macos.zsh"
}

phase_5_system_changes() {
  [[ $OSTYPE == 'darwin'* ]] || return 0
  echo "Next: Installing system-wide macOS defaults (sudo required)."
  waitconfirm
  bash macos/.macos
  echo "Done. A full restart is required for all settings to take effect."
}

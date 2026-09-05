phase_1_admin_installs() {
  install_brewfile claude/Brewfile
}

phase_2_user_installs() {
  export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1
  curl -fsSL claude.ai/install.sh | zsh -s -- stable --force
}

phase_3_dotfiles() {
  link_dotfile "claude/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  link_dotfile "claude/.claude/settings.json" "$HOME/.claude/settings.json"
  link_dotfile "claude/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_claude.zsh"
}

phase_4_post_dotfiles() {
  command -v code > /dev/null 2>&1 || return 0
  code --install-extension anthropic.claude-code
}

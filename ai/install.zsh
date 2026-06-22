phase_1_admin_installs() {
  install_brewfile ai/Brewfile
}

phase_2_user_installs() {
  # Claude CLI
  export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1
  curl -fsSL claude.ai/install.sh | zsh -s -- stable --force
}

phase_3_dotfiles() {
  link_dotfile ".claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  link_dotfile ".claude/settings.json" "$HOME/.claude/settings.json"
  link_dotfile "ai/.zshrc.d/00_ai_safe_config.zsh" "$HOME/.zshrc.d/00_ai_safe_config.zsh"
}

phase_4_post_dotfiles() {
  local chatgpt_extension="openai-chatgpt-latest.vsix"

  curl -fL "https://persistent.oaistatic.com/pair-with-ai/openai-chatgpt-latest.vsix" -o "$chatgpt_extension"
  code --install-extension "$chatgpt_extension"
  rm "$chatgpt_extension"
}

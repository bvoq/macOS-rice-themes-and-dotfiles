phase_2_user_installs() {
  curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
}

phase_5_system_changes() {
  [[ $OSTYPE == 'darwin'* ]] || return 0
  # Don't display the annoying prompt when quitting iTerm
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false
}

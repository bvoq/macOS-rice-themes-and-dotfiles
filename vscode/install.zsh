phase_3_dotfiles() {
  link_dotfile "vscode/.vscode-settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
  link_dotfile "vscode/.vscode-settings.json" "$HOME/Library/Application Support/Code - Insiders/User/settings.json"
  link_dotfile "vscode/.zshenv" "$HOME/.zshenv.d/.zshenv_vscode"
  #link_dotfile "vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
  #link_dotfile "vscode/keybindings.json" "$HOME/Library/Application Support/Code - Insiders/User/keybindings.json"
  link_dotfile "vscode/.zshrc.d/00_vscode_safe_config.zsh" "$HOME/.zshrc.d/00_vscode_safe_config.zsh"
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false
}

phase_4_post_dotfiles() {
  code --install-extension aaron-bond.better-comments
  code --install-extension johnpapa.vscode-peacock
  code --install-extension usernamehw.errorlens
  code --install-extension PKief.material-icon-theme
  code --install-extension Ho-Wan.setting-toggle
  code --install-extension ctf0.close-tabs-to-the-left
  code --install-extension ms-vsliveshare.vsliveshare

  code --install-extension eamodio.gitlens
  code --install-extesion github.vscode-github-actions
  code --install-extension GitHub.vscode-pull-request-github

  code --install-extension ifahrentholz.one-quiet-dark-pro

  code --install-extension redhat.vscode-yaml
  code --install-extension DavidAnson.vscode-markdownlint
}

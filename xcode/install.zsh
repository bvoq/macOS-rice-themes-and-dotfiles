phase_3_dotfiles() {
  link_dotfile "xcode/Zenburn.xccolortheme" "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/Zenburn.xccolortheme"
  link_dotfile "xcode/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_xcode.zsh"
  echo "You will need to manually select the Zenburn theme under Xcode > Preferences > Themes."
}

phase_1_admin_installs() {
  install_brewfile mobile/Brewfile

  # special: dcm requires its own tap
  brew tap CQLabs/dcm
  brew install dcm
}

phase_2_user_installs() {
  if [ ! -d ~/Developer/flutter ]; then
    git clone -b main https://github.com/flutter/flutter.git ~/Developer/flutter
  fi

  # maestro for testing
  [ ! -d ~/.maestro/bin ] && curl -Ls "https://get.maestro.mobile.dev" | bash
}

phase_3_dotfiles() {
  link_dotfile "mobile/.zshenv.d/mobile.zsh" "$HOME/.zshenv.d/mobile.zsh"
  link_dotfile "mobile/.zshrc.d/00_mobile_safe_config.zsh" "$HOME/.zshrc.d/00_mobile_safe_config.zsh"
}

phase_4_post_dotfiles() {
  # General:
  code --install-extension mariomatheu.syntax-project-pbxproj
  # Dart/Flutter related:
  code --install-extension Dart-Code.dart-code
  code --install-extension Dart-Code.flutter
  code --install-extension gmlewis-vscode.flutter-stylizer # nice button at bottom
  code --install-extension qlevar.pub-manager
  code --install-extension dcmdev.dcm-vscode-extension
  # Flutter test coverage:
  code --install-extension ryanluker.vscode-coverage-gutters
  code --install-extension flutterando.flutter-coverage
}

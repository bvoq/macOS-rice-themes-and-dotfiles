phase_1_admin_installs() {
  install_brewfile formal/Brewfile

  # special: PsiSolver lives on a custom tap
  brew tap bvoq/bvoq
  brew install psisolver
  # Kframework
  #brew tap kframework/k
  #brew install kframework
  ## Agda
  # brew install stack
  # stack install Agda # installs GHC automatically
  # # install emacs from mituharu: https://github.com/railwaycat/homebrew-emacsmacport
  # brew tap railwaycat/emacsmacport
  # brew install --cask emacs-mac
  # agda-mode setup
}

phase_3_dotfiles() {
  link_dotfile "formal/.zshenv" "$HOME/.zshenv.d/.zshenv_formal"
}

phase_4_post_dotfiles() {
  code --install-extension banacorn.agda-mode
  code --install-extension gpoore.codebraid-preview
}

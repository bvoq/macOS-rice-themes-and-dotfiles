phase_1_admin_installs() {
  install_brewfile formal/Brewfile
}

phase_2_user_installs() {
  # Agda is per-user: stack installs it into ~/.local/bin and agda-mode setup edits the user's emacs.
  if [ ! -x "$HOME/.local/bin/agda" ]; then
    stack install Agda # installs GHC automatically
    agda-mode setup
  fi
}

phase_3_dotfiles() {
  link_dotfile "formal/.zshenv" "$HOME/.zshenv.d/.zshenv_formal"
}

phase_4_post_dotfiles() {
  code --install-extension banacorn.agda-mode
  code --install-extension gpoore.codebraid-preview
}

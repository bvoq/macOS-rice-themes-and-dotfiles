phase_1_admin_installs() {
  install_brewfile emacs/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "emacs/.zshenv" "$HOME/.zshenv.d/.zshenv_emacs"
}

phase_4_post_dotfiles() {
  if [ ! -f ~/.config/emacs/bin/doom ]; then
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install --env
  fi

  mkdir -p ~/.config/doom
  ~/.config/emacs/bin/doom upgrade
  link_dotfile "emacs/.config/doom/cheatsheet.org" "$HOME/.config/doom/cheatsheet.org"
  link_dotfile "emacs/.config/doom/config.org" "$HOME/.config/doom/config.org"
  link_dotfile "emacs/.config/doom/init.el" "$HOME/.config/doom/init.el"
  link_dotfile "emacs/.config/doom/packages.el" "$HOME/.config/doom/packages.el"
  ~/.config/emacs/bin/doom sync
}

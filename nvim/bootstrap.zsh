phase_1_admin_installs() {
  install_brewfile nvim/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "nvim/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"
  link_dotfile "nvim/.config/nvim/ycm_extra_conf.py" "$HOME/.config/nvim/ycm_extra_conf.py"
}

phase_4_post_dotfiles() {
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

  if command -v nvim > /dev/null; then
    nvim +'PlugInstall --sync' +qa
    nvim +'PlugClean --sync' +qa
  fi
}

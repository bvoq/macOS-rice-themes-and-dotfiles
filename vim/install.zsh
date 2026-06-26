phase_3_dotfiles() {
  link_dotfile "vim/.vimrc" "$HOME/.vimrc"
  link_dotfile "vim/.zshrc.d/00_vim_safe_config.zsh" "$HOME/.zshrc.d/00_vim_safe_config.zsh"
}

phase_4_post_dotfiles() {
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  \vim +'PlugInstall --sync' +qa
  \vim +'PlugClean --sync' +qa
}

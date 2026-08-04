phase_1_admin_installs() {
  install_brewfile nvim/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "nvim/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"
  link_dotfile "nvim/.config/nvim/ycm_extra_conf.py" "$HOME/.config/nvim/ycm_extra_conf.py"
  link_dotfile "nvim/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_nvim.zsh"
}

phase_4_post_dotfiles() {
  local plug_log="$HOME/.local/state/nvim/plug-install.log"

  sh -c 'curl -fLo "$HOME/.local/share"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

  if command -v nvim > /dev/null; then
    mkdir -p "${plug_log:h}"
    : > "$plug_log"
    setopt local_options pipefail

    nvim --headless +'PlugInstall --sync' +qa 2>&1 | tee -a "$plug_log" || return
    if [[ -d "$HOME/.local/share/nvim/plugged/avante.nvim" && ! -f "$HOME/.local/share/nvim/plugged/avante.nvim/lua/avante_templates.so" ]]; then
      echo "building avante.nvim"
      (
        cd "$HOME/.local/share/nvim/plugged/avante.nvim" || exit
        make --debug=v
      ) 2>&1 | tee -a "$plug_log" || return
    fi
    nvim --headless +'PlugClean!' +qa 2>&1 | tee -a "$plug_log"
  fi
}

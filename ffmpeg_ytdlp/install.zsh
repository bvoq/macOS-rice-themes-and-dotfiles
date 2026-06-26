phase_1_admin_installs() {
  install_brewfile ffmpeg_ytdlp/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "ffmpeg_ytdlp/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_ffmpeg_ytdlp.zsh"
}

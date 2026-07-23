phase_1_admin_installs() {
  install_brewfile wezterm/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "wezterm/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
}
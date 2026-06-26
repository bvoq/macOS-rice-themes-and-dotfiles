phase_1_admin_installs() {
  install_brewfile lowlevel/Brewfile
}

phase_2_user_installs() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default --no-modify-path -y
}

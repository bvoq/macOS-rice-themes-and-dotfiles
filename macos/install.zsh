phase_5_system_changes() {
  echo "Next: Installing system-wide macOS defaults (sudo required)."
  waitconfirm
  bash macos/.macos
  echo "Done. A full restart is required for all settings to take effect."
}

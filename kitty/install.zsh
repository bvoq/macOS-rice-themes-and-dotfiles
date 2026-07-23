phase_1_admin_installs() {
  install_brewfile kitty/Brewfile
}

phase_3_dotfiles() {
  link_dotfile "kitty/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

  local kitty_dir="$HOME/.config/kitty"
  local theme_file="$kitty_dir/current-theme.conf"

  mkdir -p "$kitty_dir"

  if [[ ! -f "$theme_file" ]]; then
    cat > "$theme_file" <<'EOF'
# Local kitty theme overrides.
# This file is intentionally outside the repo and safe to customize.
# Example:
# background #fdf6e3
# foreground #657b83
EOF
  fi

  if command -v kitty > /dev/null 2>&1 && [[ -n "${KITTY_THEME:-}" ]]; then
    kitty +kitten themes --reload-in=none --config-file-name current-theme.conf "$KITTY_THEME" > /dev/null 2>&1 || {
      echo "kitty: could not apply KITTY_THEME='$KITTY_THEME'; keeping $theme_file"
    }
  fi
}

# Auto-zap packages without asking if = 1 or never zap if = 0.
# ZAP_BREW_AFTER_INSTALL = 1
# Leave unset to be asked.

phase_0_bootstrap() {
  # Install Homebrew if missing (phase_0 only runs for admins; the installer escalates via sudo).
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found; installing it."
    waitconfirm
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # The installer doesn't touch PATH; source our fragment so brew is on PATH for
    # the rest of this run (script shells don't read ~/.zprofile).
    source "brew/.zprofile"
  fi
}

_append_to_brew_bundle_accumulator() {
  local brew_file="$1"
  [[ -n "$RAZORDOT_BREW_BUNDLE_ACCUMULATOR" ]] || return 0
  {
    echo "# from $brew_file"
    cat "$brew_file"
    echo
  } >>"$RAZORDOT_BREW_BUNDLE_ACCUMULATOR"
}

install_brewfile() {
  # Lazily create one accumulator per run on first use.
  [[ -n "$RAZORDOT_BREW_BUNDLE_ACCUMULATOR" ]] || {
    export RAZORDOT_BREW_BUNDLE_ACCUMULATOR="$(mktemp -d)/Brewfile"
    : >"$RAZORDOT_BREW_BUNDLE_ACCUMULATOR"
  }
  local brew_file="$1"
  [ -f "$brew_file" ] || {
    echo "Brewfile missing: $brew_file"
    return 1
  }
  echo "\n>>> brew bundle --file=$brew_file"
  brew bundle --verbose --file="$brew_file"
  _append_to_brew_bundle_accumulator "$brew_file"
}

# zap unmentioned casks, formulae and mas.
_zap_unbundled_brew_packages() {
  [[ -n "$RAZORDOT_BREW_BUNDLE_ACCUMULATOR" && -s "$RAZORDOT_BREW_BUNDLE_ACCUMULATOR" ]] || return 0

  local cleanup_preview
  cleanup_preview="$(brew bundle cleanup --file="$RAZORDOT_BREW_BUNDLE_ACCUMULATOR" --formula --cask 2>&1 | grep -v '^Warning: Skipping ' || true)"
  echo "$cleanup_preview" | grep -q '^Would uninstall' || return 0

  echo "\nThe following installed packages are not in any active plugin Brewfile:"
  echo "$cleanup_preview"

  local do_zap
  if [[ -n "${ZAP_BREW_AFTER_INSTALL:-}" ]]; then
    do_zap="$ZAP_BREW_AFTER_INSTALL"
  elif [[ ! -t 0 ]]; then
    echo "Not running interactively; leaving these packages installed."
    return 0
  elif read -q "choice?Uninstall these packages now? [y/n] "; then
    echo
    do_zap=1
  else
    echo "\nKeeping all installed packages."
    do_zap=0
  fi

  if [[ "$do_zap" == 1 ]]; then
    brew bundle cleanup --file="$RAZORDOT_BREW_BUNDLE_ACCUMULATOR" --formula --cask --zap --force
  fi
}

phase_2_user_installs() {
  # Reconcile brew after every folder's phase_1 has run (all phase_1 complete
  # before any phase_2). Skip in single-folder mode so `--install <one>` never
  # zaps everything else, and only when we actually ran the admin installs.
  isadminuser || return 0
  ((${RAZORDOT_SINGLE_FOLDER:-0})) && return 0
  command -v brew >/dev/null 2>&1 || return 0
  brew autoremove
  brew cleanup
  _zap_unbundled_brew_packages
}

phase_3_dotfiles() {
  link_dotfile "brew/.zprofile" "$HOME/.zprofile.d/.zprofile_brew"
  link_dotfile "brew/.zshrc.d/00_safe_config.zsh" "$HOME/.zshrc.d/00_safe_config_brew.zsh"
  link_dotfile "brew/.zshrc.d/20_pre_compinit.zsh" "$HOME/.zshrc.d/20_pre_compinit_brew.zsh"
}

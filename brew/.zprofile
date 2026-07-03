# Put Homebrew on PATH (guarded so nested shells don't re-eval). Linked into
# ~/.zprofile.d so it runs after macOS path_helper, which would otherwise reorder
# brew behind /usr/bin.
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$brew_bin" ]] && eval "$("$brew_bin" shellenv)" && break
  done
  unset brew_bin
fi

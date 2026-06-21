phase_1_admin_installs() {
  echo "Next: Installing monero."
  waitconfirm
  if [ ! -d ~/monero ]; then
    git clone --recursive https://github.com/monero-project/monero ~/monero
  fi
  {
    cd ~/monero
    chmod -R u+rw ~/monero
    git fetch --all
    BRANCH=$(git ls-remote --heads origin | grep 'release-' | awk -F'/' '{print $3}' | sort -V | tail -n 1)
    echo "Using monero branch: ${BRANCH}"
    git checkout --recurse-submodules ${BRANCH}
    git submodule init
    git submodule update
    brew update
    brew bundle --verbose --file=contrib/brew/Brewfile || true # this command can fail due to empty brew taps.
    chmod -R u+rw ~/monero
    make USE_SINGLE_BUILDDIR=0 # makes sure that only a single build dir is used.
    # a few notes
    # ledger is stored in $HOME/.bitmonero. Copy for faster sync.
    # keys are stored next to monero-wallet-cli.
    # to recover use: monero-wallet-cli --restore-deterministic-wallet
  }
}

phase_3_dotfiles() {
  link_dotfile "crypto/.zshenv.d/crypto.zsh" "$HOME/.zshenv.d/crypto.zsh"
  link_dotfile "crypto/.zshrc.d/00_crypto_safe_config.zsh" "$HOME/.zshrc.d/00_crypto_safe_config.zsh"
}

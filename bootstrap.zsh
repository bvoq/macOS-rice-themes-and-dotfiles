#!/bin/zsh

# enable what you want to install here
AITOOLS=0
CRYPTO=0
FORMALMETHODS=0
GENERICTOOLS=1
GENERICCASKTOOLS=1
MOBILETOOLS=0
UNITYTOOLS=0
LOWLEVELTOOLS=0
TEXLIGHT=0
TEXFULL=0

cd "${0:A:h}"

# Enable package folders here. Comment out folders you do not want to bootstrap.
bootstrap_folders=(
  librewolf
  # ai
  # crypto
  # devops
  vim
  nvim
  emacs
  # formal
  # generic
  # generic-cask
  # lowlevel
  # mobile
  # tex-light
  # tex-full
  # unity
)

source unofunctions.zsh
set_error_handler

run_bootstrap_phase() {
  local phase="$1"
  local phase_function="phase_$phase"
  local folder bootstrap_file

  for folder in "${bootstrap_folders[@]}"; do
    bootstrap_file="$folder/bootstrap.zsh"
    [[ -f "$bootstrap_file" ]] || { echo "Bootstrap file missing: $bootstrap_file"; return 1; }

    (
      source "$bootstrap_file"
      if (( $+functions[$phase_function] )); then
        "$phase_function"
      fi
    )
  done
}

git submodule update --init --recursive

if ! [[ $OSTYPE == 'darwin'* ]]; then
  echo "This bootstrap script is only meant for macOS. Exiting."
  exit 1
fi

# macOS sanity checks
assure_userlevel_zsh
check_not_rosetta
mkdir -p ~/Developer

#############################################################
# Section 1: Brew tools and other admin-privileged installs #
#############################################################

if isadmin; then
  run_bootstrap_phase 1_admin_installs

  # clean up brew
  brew autoremove
  brew cleanup

  if [ $GENERICTOOLS = 1 ]; then
    install_brewfile brew/Brewfile.generic_crossplatform
    install_brewfile brew/Brewfile.generic_macos
  fi

  if [ $MOBILETOOLS = 1 ]; then
    install_brewfile brew/Brewfile.mobile

    # special: dcm requires its own tap
    brew tap CQLabs/dcm
    brew install dcm
  fi

  if [ $LOWLEVELTOOLS = 1 ]; then
    install_brewfile brew/Brewfile.lowlevel
  fi

  ### Formal methods
  if [ $FORMALMETHODS = 1 ]; then
    install_brewfile brew/Brewfile.formal

    # special: PsiSolver lives on a custom tap
    brew tap bvoq/bvoq
    brew install psisolver
    # Kframework
    #brew tap kframework/k
    #brew install kframework
    ## Agda
    # brew install stack
    # stack install Agda # installs GHC automatically
    # # install emacs from mituharu: https://github.com/railwaycat/homebrew-emacsmacport
    # brew tap railwaycat/emacsmacport
    # brew install --cask emacs-mac
    # agda-mode setup
  fi

  #if [ $SECURITYTOOLS = 1 ]; then
  #  # https://github.com/joxeankoret/diaphora
  #  # frida
  #fi
  if [ $GENERICCASKTOOLS = 1 ]; then
    install_brewfile brew/Brewfile.generic-cask
    # manually install regex for safari: https://apps.apple.com/ch/app/regex-for-safari/id1597580456?l=en-GB
    # manually install shortery: https://apps.apple.com/us/app/shortery/id1594183810?mt=12
    # or use visual-studio-code@insiders instead of visual-studio-code

    # reminder to self: you own a license to use this:
    #brew install daisydisk --cask
  fi

  if [ $TEXLIGHT = 1 ]; then
    # reminder to self: you own a license to use texifier:
    install_brewfile brew/Brewfile.tex-light
    ## tex light version CLI alternatives:
    # brew install --cask basictex
    # brew install --cask tex-live-utility
  fi

  if [ $TEXFULL = 1 ]; then
    # reminder to self: you own a license to use texifier:
    install_brewfile brew/Brewfile.tex-full
  fi

  if [ $AITOOLS = 1 ]; then
    install_brewfile brew/Brewfile.ai
  fi

  if [ $CRYPTO = 1 ]; then
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
  fi

else
  echo "Skipping brew and other admin-privileged installs."
fi


##################################
# Section 2: User-level installs #
##################################

echo "Installing other user-level tools."

run_bootstrap_phase 2_user_installs

if [ $GENERICTOOLS = 1 ]; then
  # zsh - antidote
  [ ! -d "${ZDOTDIR:-$HOME}/.antidote" ] && git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote

  # update ~/Library/Caches/tealdeer/
  tldr --update

  # iterm2 shell integration
  curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
fi

if [ $MOBILETOOLS = 1 ]; then
  if [ ! -d ~/Developer/flutter ]; then
    git clone -b main https://github.com/flutter/flutter.git ~/Developer/flutter
  fi

  # maestro for testing
  [ ! -d ~/.maestro/bin ] && curl -Ls "https://get.maestro.mobile.dev" | bash
fi

if [ $LOWLEVELTOOLS = 1 ]; then
  # Install rust, use --profile complete for everything.
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default --no-modify-path -y
fi

if [ $UNITYTOOLS = 1 ]; then
  # for some reason, brew install dotnet doesn't provide the right arm binaries....
  if [[ ! -d "$HOME/.dotnet" ]]; then
      mkdir -p "$HOME/.dotnet"
      ARCH=$(uname -m)
      if [[ "$ARCH" == "arm64" ]]; then
          curl "https://download.visualstudio.microsoft.com/download/pr/d81d84cf-4bb8-4371-a4d2-88699a38a83b/9bddfe1952bedc37e4130ff12abc698d/dotnet-sdk-8.0.303-osx-arm64.tar.gz" > "$HOME/dotnet.tar.gz"
      else
          curl "https://download.visualstudio.microsoft.com/download/pr/295f5e51-4d26-4706-90c1-25b745cd2abf/ef976bfc166782e519036ee7670eac36/dotnet-sdk-8.0.303-osx-x64.tar.gz" > "$HOME/dotnet.tar.gz"
      fi
      tar -xzvf "$HOME/dotnet.tar.gz" -C "$HOME/.dotnet"
      rm "$HOME/dotnet.tar.gz"
  fi
fi

if [ $AITOOLS = 1 ]; then
  # Claude CLI
  export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1
  curl -fsSL claude.ai/install.sh | zsh -s -- stable --force
fi

#########################################################
# Section 3: Dotfiles (user-level) install and sourcing #
#########################################################

echo "Linking dotfiles after installation, because some install script like to add stuff to .zshrc (evil right?!?)."

run_bootstrap_phase 3_dotfiles

link_dotfile ".claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_dotfile ".claude/settings.json" "$HOME/.claude/settings.json"
link_dotfile ".inputrc" "$HOME/.inputrc"
link_dotfile ".gitconfig" "$HOME/.gitconfig"
link_dotfile ".gitignore_global" "$HOME/.gitignore_global"
link_dotfile ".gitattributes_global" "$HOME/.gitattributes_global"
link_dotfile ".tmux.conf" "$HOME/.tmux.conf"
link_dotfile ".zshrc" "$HOME/.zshrc"
link_dotfile ".zshenv" "$HOME/.zshenv"
link_dotfile "unofunctions.zsh" "$HOME/.unofunctions.zsh"
link_dotfile ".zshfunctions" "$HOME/.zshfunctions"
link_dotfile ".zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
link_dotfile "starship.toml" "$HOME/.config/starship.toml"

# macOS specific dotfile changes.
if [[ $OSTYPE == 'darwin'* ]]; then
  link_dotfile "vscode/.vscode-settings.json" "$HOME/Library/Application Support/Code/User/settings.json" # VSCode
  link_dotfile "vscode/.vscode-settings.json" "$HOME/Library/Application Support/Code - Insiders/User/settings.json" # VSCode Insiders
  #link_dotfile "vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json" # VSCode
  #link_dotfile "vscode/keybindings.json" "$HOME/Library/Application Support/Code - Insiders/User/keybindings.json" # VSCode Insiders
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false # VSCode
  defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false # VSCode Insiders
  
  link_dotfile "xcode/Zenburn.xccolortheme" "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/Zenburn.xccolortheme"
  echo "You will need to manually select the Zenburn theme under Xcode > Preferences > Themes."
  echo "Further, you will need to manually install the Zenburn themes for Terminal.app and iTerm2.app"

fi

source ~/.zshrc  # Source the new zshrc with antidote

####################################################################################
# Section 4: Installing user-level tools that require the dotfiles to be in place. #
####################################################################################

run_bootstrap_phase 4_post_dotfiles

echo "Installing VSCode extensions"
waitconfirm
# General
code --install-extension aaron-bond.better-comments
code --install-extension johnpapa.vscode-peacock
code --install-extension usernamehw.errorlens
code --install-extension PKief.material-icon-theme
code --install-extension Ho-Wan.setting-toggle
code --install-extension ctf0.close-tabs-to-the-left
code --install-extension ms-vsliveshare.vsliveshare
# Git related
code --install-extension eamodio.gitlens
code --install-extesion github.vscode-github-actions
code --install-extension GitHub.vscode-pull-request-github
# Theme
code --install-extension ifahrentholz.one-quiet-dark-pro
# Generic linters
code --install-extension redhat.vscode-yaml
code --install-extension DavidAnson.vscode-markdownlint
if [ $AITOOLS = 1 ]; then
    curl "https://persistent.oaistatic.com/pair-with-ai/openai-chatgpt-latest.vsix" > openai-chatgpt-latest.vsix
    code --install-extension openai-chatgpt-latest.vsix
    rm openai-chatgpt-latest.vsix
  fi

if [ $UNITYTOOLS = 1 ]; then
  # Note this also installs its own dotnet runtime, but not dotnet sdk!
  code --install-extension visualstudiotoolsforunity.vstuc
fi

if [ $FORMALMETHODS = 1 ]; then
  code --install-extension banacorn.agda-mode
  code --install-extension gpoore.codebraid-preview
fi

if [ $MOBILETOOLS = 1 ]; then
  # General:
  code --install-extension mariomatheu.syntax-project-pbxproj
  # Dart/Flutter related:
  code --install-extension Dart-Code.dart-code
  code --install-extension Dart-Code.flutter
  code --install-extension gmlewis-vscode.flutter-stylizer # nice button at bottom
  code --install-extension qlevar.pub-manager
  code --install-extension dcmdev.dcm-vscode-extension
  # Flutter test coverage:
  code --install-extension ryanluker.vscode-coverage-gutters
  code --install-extension flutterando.flutter-coverage
fi

####################################################################
# Section 5: Heavy macOS system changes, requires admin and reboot #
####################################################################

# System changes for macOS
if [[ $OSTYPE == 'darwin'* ]] && isadmin; then
  run_bootstrap_phase 5_system_changes

  echo "Next: Installing system-wide macOS defaults (sudo required)."
  waitconfirm
  bash .macos
  echo "Done. A full restart is required for all settings to take effect."
fi

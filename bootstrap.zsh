#!/bin/zsh

# enable what you want to install here
AITOOLS=0
CRYPTO=0
FORMALMETHODS=0
GENERICTOOLS=1
GENERICCASKTOOLS=1
DEVOPSTOOLS=0
MOBILETOOLS=0
UNITYTOOLS=0
LOWLEVELTOOLS=0
TEXLIGHT=0
TEXFULL=0

source .zshfunctions
set_error_handler

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
  # clean up brew
  brew autoremove
  brew cleanup

  if [ $GENERICTOOLS = 1 ]; then
    install_brewfile brew/Brewfile.generic_crossplatform
    install_brewfile brew/Brewfile.generic_macos

    # apple essentials: rbenv-managed Ruby + cocoapods (special: needs version pin)
    if [ ! -d "$HOME/.rbenv/versions/3.3.0" ]; then
      rbenv install 3.3.0
      rbenv global 3.3.0
    fi
    eval "$(rbenv init - zsh --no-rehash)"
    gem install cocoapods
    rbenv rehash 2>/dev/null || true  # see: https://github.com/rbenv/rbenv/pull/1641

    # zsh - antidote
    [ ! -d "${ZDOTDIR:-$HOME}/.antidote" ] && git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote

    # iterm2 shell integration
    curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
  fi

  if [ $MOBILETOOLS = 1 ]; then
    install_brewfile brew/Brewfile.mobile

    # special: dcm requires its own tap
    brew tap CQLabs/dcm
    brew install dcm

    if [ ! -d ~/Developer/flutter ]; then
      git clone -b main https://github.com/flutter/flutter.git ~/Developer/flutter
    fi

    # maestro for testing
    [ ! -d ~/.maestro/bin ] && curl -Ls "https://get.maestro.mobile.dev" | bash
  fi

  if [ $LOWLEVELTOOLS = 1 ]; then
    install_brewfile brew/Brewfile.lowlevel
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

  if [ $DEVOPSTOOLS = 1 ]; then
    install_brewfile brew/Brewfile.devops

    # special: kubetail lives on a custom tap
    brew tap johanhaleby/kubetail && brew install kubetail

    # special: krew (kubectl plugin manager) is shipped as a curl-installer
    (
      set -x; cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
    )
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

    # Claude CLI
    export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1
    curl -fsSL claude.ai/install.sh | zsh -s -- stable --force
  fi

else
  echo "Skipping brew and other admin-privileged installs."
fi


#####################################################
# Section 2: Dotfiles and other user-level installs #
#####################################################

# Copy dotfiles after installation, because some install script like to add stuff to .zshrc (evil right?!?)
# create a backup, better safe than sorry.
[ -f ~/.emacs ] && mv ~/.emacs     ~/.emacs.old
[ -f ~/.inputrc ] && mv ~/.inputrc   ~/.inputrc.old
[ -f ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.old
[ -f ~/.gitattributes_global ] && mv ~/.gitattributes_global ~/.gitattributes_global.old
[ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.old
[ -d ~/.tmux ] && mv ~/.tmux ~/.tmux.old
[ -f ~/.vimrc ] && mv ~/.vimrc     ~/.vimrc.old
[ -f ~/.config ] && mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.old
[ -f ~/.zshrc ] && mv ~/.zshrc     ~/.zshrc.old
[ -f ~/.zshfunctions ] && mv ~/.zshfunctions ~/.zshfunctions.old
[ -f ~/.zshenv ] && mv ~/.zshenv     ~/.zshenv.old
[ -f ~/.config/starship.toml ] && mv ~/.config/starship.toml ~/.config/starship.toml.old

cp .claude/CLAUDE.md ~/.claude/CLAUDE.md
cp .claude/settings.json ~/.claude/settings.json
cp .emacs ~/.emacs
cp .inputrc   ~/.inputrc
cp .gitconfig ~/.gitconfig
cp .gitignore_global ~/.gitignore_global
cp .gitattributes_global ~/.gitattributes_global
cp .tmux.conf ~/.tmux.conf
cp .zshrc     ~/.zshrc
cp .zshenv    ~/.zshenv
cp .zshfunctions ~/.zshfunctions
cp .zsh_plugins.txt ~/.zsh_plugins.txt
mkdir -p ~/.config && cp starship.toml ~/.config/starship.toml

source ~/.zshrc  # Source the new zshrc with antidote


if [[ $OSTYPE == 'darwin'* ]]; then
  [ -f ~/Library/Application\ Support/Code/User/settings.json ] && mv ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.old
  mkdir -p ~/Library/Application\ Support/Code/User
  mkdir -p ~/Library/Application\ Support/Code\ -\ Insiders/User
  cp vscode/.vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json # VSCode
  cp vscode/.vscode-settings.json ~/Library/Application\ Support/Code\ -\ Insiders/User/settings.json # VSCode Insiders
  #cp vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings # VSCode
  #cp vscode/keybindings.json ~/Library/Application\ Support/Code\ -\ Insiders/User/keybindings.json # VSCode Insiders
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false # VSCode
  defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false # VSCode Insiders
fi


echo "Installing Vim and Neovim configurations and plugins"

# Install vim and neovim
# install vundle for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# install vundle for nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# copy the vim config files
mkdir -p ~/.config/nvim && cp .config/nvim/init.vim ~/.config/nvim/init.vim
cp .vimrc ~/.vimrc
if command -v nvim > /dev/null; then
  nvim +'PlugInstall --sync' +qa
  nvim +'PlugClean --sync' +qa
fi
\vim +'PlugInstall --sync' +qa
\vim +'PlugClean --sync' +qa

echo "To enable trace, run: 'csrutil enable --without dtrace --without debug' in reboot mode."

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


if [ $CRYPTO = 1 ] && isadmin; then
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
    brew bundle --file=contrib/brew/Brewfile || true # this command can fail due to empty brew taps.
    chmod -R u+rw ~/monero
    make USE_SINGLE_BUILDDIR=0 # makes sure that only a single build dir is used.
    # a few notes
    # ledger is stored in $HOME/.bitmonero. Copy for faster sync.
    # keys are stored next to monero-wallet-cli.
    # to recover use: monero-wallet-cli --restore-deterministic-wallet
  }
fi
if [ $MOBILETOOLS = 1 ] && isadmin; then
  echo "Next: Installing firebase, requires root permission."
  waitconfirm
  curl -sL https://firebase.tools | bash
  dart pub global activate flutterfire_cli 0.3.0-dev.16 --overwrite
fi



#########################################################
# Section 3: Heavy macOS system changes, requires admin #
#########################################################

# System changes for macOS
if [[ $OSTYPE == 'darwin'* ]] && isadmin; then
  echo "Next: Installing system changes for macOS."
  waitconfirm

  bash .macos
  echo "Almost done. Next we will install some Terminal and Xcode themes. You can also install them manually alternatively."
  waitconfirm
  mkdir -p ~/Library/Developer/Xcode/UserData/FontAndColorThemes/ && cp xcode/Zenburn.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/Zenburn.xccolortheme
  echo "Done. It will need to be manually selected under Xcode > Preferences > Themes > Zenburn"
  echo "Also, in the new Xcode you may need to set Xcode > Preferences > General > Appearance > Dark"
  echo "Afer this Terminal.app will be killed. Note that in order to apply all settings a full restart is required."
  waitconfirm

  cp terminal/com.apple.Terminal.plist ~/Library/Preferences/com.apple.Terminal.plist
  defaults read com.apple.Terminal
  echo "Done. Goodbye."
  killall "Terminal"
fi

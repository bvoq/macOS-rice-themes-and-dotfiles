#!/bin/zsh

# enable what you want to install here
LOWLEVELTOOLS=0

cd "${0:A:h}"

# Enable package folders here. Comment out folders you do not want to bootstrap.
bootstrap_folders=(
  librewolf
  rclone
  generic
  # ai
  # crypto
  # devops
  generic-cask
  vim
  nvim
  emacs
  # formal
  # lowlevel
  # mobile
  # tex
  # csharp
)

source unofunctions.zsh
set_error_handler

run_bootstrap_phase() {
  local phase="$1"
  local phase_function="phase_$phase"
  local folder install_file

  for folder in "${bootstrap_folders[@]}"; do
    install_file="$folder/install.zsh"
    [[ -f "$install_file" ]] || { echo "Install file missing: $install_file"; return 1; }

    (
      source "$install_file"
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

  if [ $LOWLEVELTOOLS = 1 ]; then
    install_brewfile brew/Brewfile.lowlevel
  fi

  #if [ $SECURITYTOOLS = 1 ]; then
  #  # https://github.com/joxeankoret/diaphora
  #  # frida
  #fi
else
  echo "Skipping brew and other admin-privileged installs."
fi


##################################
# Section 2: User-level installs #
##################################

echo "Installing other user-level tools."

run_bootstrap_phase 2_user_installs

if [ $LOWLEVELTOOLS = 1 ]; then
  # Install rust, use --profile complete for everything.
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default --no-modify-path -y
fi

#########################################################
# Section 3: Dotfiles (user-level) install and sourcing #
#########################################################

echo "Linking dotfiles after installation, because some install script like to add stuff to .zshrc (evil right?!?)."

run_bootstrap_phase 3_dotfiles

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

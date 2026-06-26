#!/bin/zsh

# enable what you want to install here
cd "${0:A:h}"

# Enable package folders here. Comment out folders you do not want to bootstrap.
bootstrap_folders=(
  librewolf
  rclone
  generic
  git
  tmux
  readline
  macos
  # ai
  # crypto
  # devops
  generic-cask
  vscode
  xcode
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

#########################################################
# Section 3: Dotfiles (user-level) install and sourcing #
#########################################################

echo "Linking dotfiles after installation, because some install script like to add stuff to .zshrc (evil right?!?)."

run_bootstrap_phase 3_dotfiles

link_dotfile ".zshrc" "$HOME/.zshrc"
link_dotfile ".zshenv" "$HOME/.zshenv"
link_dotfile "unofunctions.zsh" "$HOME/.unofunctions.zsh"
link_dotfile ".zshfunctions" "$HOME/.zshfunctions"
link_dotfile ".zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
link_dotfile "starship.toml" "$HOME/.config/starship.toml"

source ~/.zshrc  # Source the new zshrc with antidote

####################################################################################
# Section 4: Installing user-level tools that require the dotfiles to be in place. #
####################################################################################

run_bootstrap_phase 4_post_dotfiles

####################################################################
# Section 5: Heavy macOS system changes, requires admin and reboot #
####################################################################

# System changes for macOS
if [[ $OSTYPE == 'darwin'* ]] && isadmin; then
  run_bootstrap_phase 5_system_changes
fi

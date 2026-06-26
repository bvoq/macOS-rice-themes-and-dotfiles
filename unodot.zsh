#!/bin/zsh

# enable what you want to install here
cd "${0:A:h}"

# Enable package folders here. Comment out folders you do not want to bootstrap.
bootstrap_folders=(
  # ai
  antidote
  brew
  # crypto
  # csharp
  # devops
  emacs
  # formal
  generic
  generic-cask
  git
  librewolf
  # lowlevel
  macos
  # mobile
  nvim
  rclone
  readline
  ripgrep
  starship
  # tex
  tmux
  vim
  vscode
  xcode
)

install_scripts=(${^bootstrap_folders}/install.zsh)

source unofunctions.zsh
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

  reset_brew_bundle_accumulator

  for install_script in "${install_scripts[@]}"; do
    phase_1_admin_installs() { :; }
    source "$install_script"
    phase_1_admin_installs
  done

  prune_unbundled_brew_packages

  # clean up brew
  brew autoremove
  brew cleanup
else
  echo "Skipping brew and other admin-privileged installs."
fi


##################################
# Section 2: User-level installs #
##################################

echo "Installing other user-level tools."

for install_script in "${install_scripts[@]}"; do
  phase_2_user_installs() { :; }
  source "$install_script"
  phase_2_user_installs
done

#########################################################
# Section 3: Dotfiles (user-level) install and sourcing #
#########################################################

echo "Linking dotfiles after installation, because some install script like to add stuff to .zshrc (evil right?!?)."

for install_script in "${install_scripts[@]}"; do
  phase_3_dotfiles() { :; }
  source "$install_script"
  phase_3_dotfiles
done

link_dotfile ".zshrc" "$HOME/.zshrc"
link_dotfile ".zshenv" "$HOME/.zshenv"
link_dotfile "unofunctions.zsh" "$HOME/.unofunctions.zsh"
link_dotfile ".zshfunctions" "$HOME/.zshfunctions"

source ~/.zshrc  # Source the new zshrc with antidote

####################################################################################
# Section 4: Installing user-level tools that require the dotfiles to be in place. #
####################################################################################

for install_script in "${install_scripts[@]}"; do
  phase_4_post_dotfiles() { :; }
  source "$install_script"
  phase_4_post_dotfiles
done

##############################################################
# Section 5: Heavy system changes, requires admin and reboot #
##############################################################

if isadmin; then
  for install_script in "${install_scripts[@]}"; do
    phase_5_system_changes() { :; }
    source "$install_script"
    phase_5_system_changes
  done
fi

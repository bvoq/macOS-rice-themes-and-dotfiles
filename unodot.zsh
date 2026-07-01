#!/bin/zsh

# Enable package folders here. Comment out folders you do not want to install.
bootstrap_folders=(
  # ai
  antidote
  brew
  core
  # crypto
  # csharp
  # devops
  emacs
  ffmpeg_ytdlp
  # formal
  generic
  generic-cask
  git
  iterm
  librewolf
  # lowlevel
  macos
  mobile
  nvim
  rclone
  readline
  ripgrep
  ruby
  ssdeep
  starship
  # tex
  tmux
  vim
  vscode
  xcode
)

# Enable/Disable options here.
UNODOT_AUTOUPDATE=1

# Do not touch anything below here.

cd "${0:a:h}"

# Optional: `./unodot.zsh --install <folder>` runs only that single plugin folder (even for disabled folders).
if [[ "$1" == "--install" ]]; then
  folder="${2%/}"
  if [[ ! -f "$folder/install.zsh" ]]; then
    echo "Usage: ${0:t} --install <folder>  (no '$folder/install.zsh' found)"
    exit 1
  fi
  bootstrap_folders=("$folder")
  unset folder
  single_folder_install=1
fi

install_scripts=(${^bootstrap_folders}/install.zsh)

isadmin() { id -G $1 | grep -q -w 80 ; }

waitconfirm() {
    if read -q "choice?Continue [press y/n]? "; then
        echo "Continuing..."
    else
        exit 0
    fi
}

bash_error_handler() {
    # Iterate over the stack trace to find the original error location
    echo "Encountered an error. Stacktrace:"
    for (( i=${#BASH_SOURCE[@]}-1; i >= 0; i-- )); do
        if [[ $i == 0 ]]; then
            args=("$@")
            file="${args[0]}"
            lineno="E" # the executed command
            content_on_line="${args[*]:2}"
        else
            file="${BASH_SOURCE[$i]}"
            lineno="${BASH_LINENO[$((i-1))]}"
            content_on_line=$(awk "NR == $lineno" "$file")
        fi
        trimmed_line=$(echo "$content_on_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [[ ${#trimmed_line} -gt 50 ]]; then
            limited_line="${trimmed_line:0:47}..."
        else
            limited_line="$trimmed_line"
        fi
        padded_line=$(printf "%-50s" "$limited_line")
        echo -e "\t$padded_line  on line $lineno\t in file $file"
    done
}

# A function that returns nonzero without tripping errexit in-context (e.g. the
# left side of `a && b`, or an explicit `return 1`) unwinds its frame before the
# ERR trap fires at the call site, so funcfiletrace no longer holds the failing
# line. The DEBUG trap records each command's location before it runs, keeping
# the true inner line available to the error handler even after the unwind.
_zsh_error_handler_command_location() {
    ZSH_ERROR_HANDLER_LAST_LOCATION="${funcfiletrace[1]}"
}

_zsh_error_handler_source_line() {
    local file="$1" lineno="$2"
    local content_on_line trimmed_line limited_line padded_line
    content_on_line="$(awk "NR == $lineno" "$file" 2>/dev/null)"
    trimmed_line=$(echo "$content_on_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ ${#trimmed_line} -gt 50 ]]; then
        limited_line="${trimmed_line:0:47}..."
    else
        limited_line="$trimmed_line"
    fi
    padded_line=$(printf "%-50s" "$limited_line")
    echo "\t$padded_line  on line $lineno\t in file $file."
}

zsh_error_handler() {
    # Iterate over the stack trace to find the original error location
    echo "Encountered an error. Stacktrace:"
    for (( i=${#funcfiletrace[@]}; i >= 1; i-- )); do
        fileandlineno=${funcfiletrace[i]}
        file=${fileandlineno%%:*}  # Get the first part before the first ':'
        lineno=${fileandlineno##*:}  # Get the last part after the last ':'
        _zsh_error_handler_source_line "$file" "$lineno"
    done
    # The walk is outermost-first, so the deepest live frame is last. When the
    # failing frame already unwound (e.g. short-circuit left side, return 1) it
    # is absent from funcfiletrace; append the DEBUG-recorded line so the true
    # failure is still the last entry.
    if [[ -n "$ZSH_ERROR_HANDLER_LAST_LOCATION" && "$ZSH_ERROR_HANDLER_LAST_LOCATION" != "${funcfiletrace[1]}" ]]; then
        _zsh_error_handler_source_line "${ZSH_ERROR_HANDLER_LAST_LOCATION%%:*}" "${ZSH_ERROR_HANDLER_LAST_LOCATION##*:}"
    fi
}

set_error_handler() {
    if [[ $SHELL == "/bin/bash" ]]; then
        set -eE -o functrace
        trap 'bash_error_handler ${BASH_SOURCE} ${BASH_COMMAND} ${BASH_ARGV[@]}' ERR
    elif [[ $SHELL == "/bin/zsh" ]]; then
        set -e
        trap '_zsh_error_handler_command_location' DEBUG
        trap 'zsh_error_handler' ERR
    else
        echo "No error handler for shell $SHELL"
    fi
}

# Phase 1 records every installed Brewfile here so that, once all plugins have
# run, unodot can compare the set of declared packages against what is actually
# installed and offer to prune the difference.
reset_brew_bundle_accumulator() {
  export UNODOT_BREW_BUNDLE_ACCUMULATOR="$(mktemp -d)/Brewfile"
  : > "$UNODOT_BREW_BUNDLE_ACCUMULATOR"
}

_append_to_brew_bundle_accumulator() {
  local brew_file="$1"
  [[ -n "$UNODOT_BREW_BUNDLE_ACCUMULATOR" ]] || return 0
  {
    echo "# from $brew_file"
    cat "$brew_file"
    echo
  } >> "$UNODOT_BREW_BUNDLE_ACCUMULATOR"
}

install_brewfile() {
  local brew_file="$1"
  [ -f "$brew_file" ] || { echo "Brewfile missing: $brew_file"; return 1; }
  echo "\n>>> brew bundle --file=$brew_file"
  brew bundle --verbose --file="$brew_file"
  _append_to_brew_bundle_accumulator "$brew_file"
}

# Compares installed formulae/casks against the accumulated Brewfiles and, when
# installed packages are not declared by any active plugin, lists them and asks
# whether to uninstall. Scoped to formulae and casks: taps, VSCode extensions,
# Mac App Store apps and the like are deliberately left untouched.
prune_unbundled_brew_packages() {
  [[ -n "$UNODOT_BREW_BUNDLE_ACCUMULATOR" && -s "$UNODOT_BREW_BUNDLE_ACCUMULATOR" ]] || return 0

  local cleanup_preview
  cleanup_preview="$(brew bundle cleanup --file="$UNODOT_BREW_BUNDLE_ACCUMULATOR" --formula --cask 2>&1 | grep -v '^Warning: Skipping ' || true)"
  echo "$cleanup_preview" | grep -q '^Would uninstall' || return 0

  echo "\nThe following installed packages are not in any active plugin Brewfile:"
  echo "$cleanup_preview"

  if [[ ! -t 0 ]]; then
    echo "Not running interactively; leaving these packages installed."
    return 0
  fi

  if read -q "choice?Uninstall these packages now? [y/n] "; then
    echo
    brew bundle cleanup --file="$UNODOT_BREW_BUNDLE_ACCUMULATOR" --formula --cask --zap --force
  else
    echo "\nKeeping all installed packages."
  fi
}

link_dotfile() {
    local source_path="${1:a}"
    local target_path="${2:a}"
    local backup_root="$PWD/backups"
    local backup_path

    [[ -e "$source_path" || -L "$source_path" ]] || { echo "Dotfile source missing: $source_path"; return 1; }

    if [[ "$target_path" == "$HOME/"* ]]; then
        backup_path="$backup_root/home/${target_path#$HOME/}"
    else
        backup_path="$backup_root/absolute/${target_path#/}"
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
            return 0
        fi

        local backup_base="$backup_path"
        local backup_suffix=1
        while [[ -e "$backup_path" || -L "$backup_path" ]]; do
            backup_path="$backup_base.$backup_suffix"
            (( backup_suffix++ ))
        done

        mkdir -p "${backup_path:h}"
        mv "$target_path" "$backup_path"
    fi

    mkdir -p "${target_path:h}"
    ln -sfn "$source_path" "$target_path"
}

# Darwin specific
assure_userlevel_zsh() {
    if [[ "$(dscl . -read ~/ UserShell)" == */bin/bash ]]; then
        echo "Your current user shell is /bin/bash. Let's change this to zsh."
        echo "This script will execute: chsh -s /bin/zsh"
        waitconfirm
        chsh -s /bin/zsh
    fi
}

check_not_rosetta() {
    if [[ "$(uname -m)" == "arm64" && "$(sysctl -n sysctl.proc_translated)" != 0 ]]; then
        echo "It seems you are running this script with Rosetta enabled."
        echo "Make sure that this terminal or session has Rosetta turned off."
        echo "For example: Right-Click Terminal > Get Info > Uncheck Open using Rosetta"
        exit 1
    fi
}

set_error_handler

git submodule update --init --recursive  # in case your repo has submodules.

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

  brew autoremove
  brew cleanup
  (( ${single_folder_install:-0} )) || prune_unbundled_brew_packages

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

# ~/.zshrc and ~/.zshenv are tiny loaders that just source the ~/.zshrc.d and
# ~/.zshenv.d fragments linked by the plugin folders above.
mkdir -p backups
{ [[ -e "$HOME/.zshenv" || -L "$HOME/.zshenv" ]] } && mv "$HOME/.zshenv" backups/.zshenv
{ [[ -e "$HOME/.zshrc" || -L "$HOME/.zshrc" ]] } && mv "$HOME/.zshrc" backups/.zshrc

cat > "$HOME/.zshenv" <<'UNODOT_ZSHENV'
#!/bin/zsh

for zshenv_file in "${ZDOTDIR:-$HOME}"/.zshenv.d/.zshenv_*(N); do
  source "$zshenv_file"
done
unset zshenv_file
UNODOT_ZSHENV

cat > "$HOME/.zshrc" <<'UNODOT_ZSHRC'
#!/bin/zsh

for zshrc_file in "${ZDOTDIR:-$HOME}"/.zshrc.d/*.zsh(N); do
  source "$zshrc_file"
  (( ${UNODOT_STOP:-0} )) && break
done
unset zshrc_file UNODOT_STOP
UNODOT_ZSHRC

source ~/.zshrc

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

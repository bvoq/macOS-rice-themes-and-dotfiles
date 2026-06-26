phase_1_admin_installs() {
  install_brewfile devops/Brewfile

  # special: kubetail lives on a custom tap
  brew tap johanhaleby/kubetail && brew install kubetail
}

phase_2_user_installs() {
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
}

phase_3_dotfiles() {
  link_dotfile "devops/.zshrc.d/00_devops_safe_config.zsh" "$HOME/.zshrc.d/00_devops_safe_config.zsh"
  link_dotfile "devops/.zshrc.d/50_devops_ishell_setup.zsh" "$HOME/.zshrc.d/50_devops_ishell_setup.zsh"
  link_dotfile "devops/.zshenv" "$HOME/.zshenv.d/.zshenv_devops"
}

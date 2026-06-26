phase_2_user_installs() {
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
}

phase_3_dotfiles() {
  link_dotfile "csharp/.zshenv.d/csharp.zsh" "$HOME/.zshenv.d/csharp.zsh"
}

phase_4_post_dotfiles() {
  # Note this also installs its own dotnet runtime, but not dotnet sdk!
  command -v code >/dev/null 2>&1 && code --install-extension visualstudiotoolsforunity.vstuc
}

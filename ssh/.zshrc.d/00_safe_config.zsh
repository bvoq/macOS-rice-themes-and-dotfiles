setupnewsshkey() {
  [ ${#} -eq 3 ] || {
    echo "Usage: setupnewsshkey <name> <email> <host>" >&2
    return 1
  }

  setupnewsshkey_name=$1
  setupnewsshkey_email=$2
  setupnewsshkey_host=$3
  setupnewsshkey_config=$HOME/.ssh/config
  setupnewsshkey_key=$HOME/.ssh/id_$setupnewsshkey_name

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [ -f "$setupnewsshkey_config" ] && awk -v wanted_host="$setupnewsshkey_host" '
      tolower($1) == "host" { in_host = 0; for (i = 2; i <= NF; i++) if ($i == wanted_host) in_host = 1; next }
      in_host && tolower($1) == "identityfile" { found = 1 }
      END { exit found ? 0 : 1 }
    ' "$setupnewsshkey_config"; then
    echo "SSH config already has an IdentityFile for host $setupnewsshkey_host. Aborting." >&2
    return 1
  fi

  if [ -e "$setupnewsshkey_key" ] || [ -e "$setupnewsshkey_key.pub" ]; then
    echo "SSH key already exists: $setupnewsshkey_key. Aborting." >&2
    return 1
  fi

  ssh-keygen -t ed25519 -C "$setupnewsshkey_email" -f "$setupnewsshkey_key" || return 1
  eval "$(ssh-agent -s)" || return 1
  case "$(uname -s)" in
    Darwin*) ssh-add --apple-use-keychain "$setupnewsshkey_key" || return 1 ;;
    *) ssh-add "$setupnewsshkey_key" || return 1 ;;
  esac

  if [ -s "$setupnewsshkey_config" ]; then
    printf '\n' >> "$setupnewsshkey_config"
  fi
  {
    printf 'Host %s\n' "$setupnewsshkey_host"
    printf '  AddKeysToAgent yes\n'
    case "$(uname -s)" in
      Darwin*) printf '  UseKeychain yes\n' ;;
    esac
    printf '  IdentityFile ~/.ssh/id_%s\n' "$setupnewsshkey_name"
  } >> "$setupnewsshkey_config"
  chmod 600 "$setupnewsshkey_config"

  if command -v pbcopy > /dev/null 2>&1; then
    pbcopy < "$setupnewsshkey_key.pub"
    echo "Public key copied to clipboard."
  else
    cat "$setupnewsshkey_key.pub"
  fi

  unset setupnewsshkey_name setupnewsshkey_email setupnewsshkey_host setupnewsshkey_config setupnewsshkey_key
}

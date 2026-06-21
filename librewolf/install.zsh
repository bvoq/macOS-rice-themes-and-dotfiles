phase_1_admin_installs() {
  local url latest_version installed_version tmp_dir dmg_path mount_point expected_sha256 actual_sha256

  url="$(curl -fsSL https://librewolf.net/installation/macos/ | grep -Eo 'https://dl\.librewolf\.net/librewolf/[^"]*macos-arm64-package\.dmg' | head -n 1)"
  [[ -n "$url" ]] || { echo "Could not find latest LibreWolf arm64 DMG."; return 1; }
  latest_version="${${${url:t}#librewolf-}%-macos-arm64-package.dmg}"

  if [[ -x /Applications/LibreWolf.app/Contents/MacOS/librewolf ]]; then
    installed_version="$(/Applications/LibreWolf.app/Contents/MacOS/librewolf --version | awk '{print $NF}')"
    [[ "$installed_version" == "$latest_version" ]] && return 0
  fi

  tmp_dir="$(mktemp -d)"
  dmg_path="$tmp_dir/LibreWolf.dmg"
  mount_point="$tmp_dir/mount"
  mkdir -p "$mount_point"

  curl -fL "$url" -o "$dmg_path"
  expected_sha256="$(curl -fsSL "$url.sha256sum" | awk '{print $1}')"
  actual_sha256="$(shasum -a 256 "$dmg_path" | awk '{print $1}')"
  if [[ "$expected_sha256" != "$actual_sha256" ]]; then
    echo "WARNING: LibreWolf checksum mismatch (expected: $expected_sha256, actual: $actual_sha256)" >&2
    rm -rf "$tmp_dir"
    return 1
  fi

  hdiutil attach -nobrowse -readonly -mountpoint "$mount_point" "$dmg_path"
  rm -rf /Applications/LibreWolf.app
  ditto "$mount_point/LibreWolf.app" /Applications/LibreWolf.app
  hdiutil detach "$mount_point"
  xattr -dr com.apple.quarantine /Applications/LibreWolf.app
  rm -rf "$tmp_dir"

  link_dotfile "librewolf/policies.json" "/Applications/LibreWolf.app/Contents/Resources/distribution/policies.json"
}

phase_2_user_installs() {
  local librewolf_bin="/Applications/LibreWolf.app/Contents/MacOS/librewolf"
  local support_dir="$HOME/Library/Application Support/librewolf"
  local profiles_ini="$support_dir/profiles.ini"
  local tmp_dir updater_path profile_path profile_key
  local -a profile_candidates
  typeset -A seen_profiles

  [[ -x "$librewolf_bin" ]] || { echo "LibreWolf must be installed before arkenfox."; return 1; }

  # LibreWolf creates the initial profile on first launch.
  # if ! grep -q '^Path=' "$profiles_ini" 2>/dev/null; then
  #   "$librewolf_bin" -CreateProfile default-release
  # fi

  while IFS= read -r profile_path; do
    profile_candidates+=("$support_dir/${profile_path#Path=}")
  done < <(grep '^Path=' "$profiles_ini" 2>/dev/null || true)

  [[ ${#profile_candidates[@]} -eq 0 ]] && return 0

  tmp_dir="$(mktemp -d)"
  updater_path="$tmp_dir/updater.sh"
  curl -fsSL https://raw.githubusercontent.com/arkenfox/user.js/master/updater.sh -o "$updater_path"
  chmod u+x "$updater_path"

  for profile_path in "${profile_candidates[@]}"; do
    [[ -d "$profile_path" ]] || continue
    profile_key="${profile_path:A}"
    [[ -n "${seen_profiles[$profile_key]}" ]] && continue
    seen_profiles[$profile_key]=1

    if [[ -f "$profile_path/user-overrides.js" ]]; then
      "$updater_path" -d -s -b -p "$profile_path"
    else
      "$updater_path" -d -s -b -n -p "$profile_path"
    fi
  done

  rm -rf "$tmp_dir"
}

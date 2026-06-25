phase_1_admin_installs() {
  local url latest_version installed_version tmp_dir dmg_path mount_point expected_sha256 actual_sha256 needs_install=1

  url="$(curl -fsSL https://librewolf.net/installation/macos/ | grep -Eo 'https://dl\.librewolf\.net/librewolf/[^"]*macos-arm64-package\.dmg' | head -n 1)"
  [[ -n "$url" ]] || { echo "Could not find latest LibreWolf arm64 DMG."; return 1; }
  latest_version="${${${url:t}#librewolf-}%-macos-arm64-package.dmg}"

  if [[ -x /Applications/LibreWolf.app/Contents/MacOS/librewolf ]]; then
    installed_version="$(/Applications/LibreWolf.app/Contents/MacOS/librewolf --version | awk '{print $NF}')"
    [[ "$installed_version" == "$latest_version" ]] && needs_install=0
  fi

  if (( needs_install )); then
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
  fi

  link_dotfile "librewolf/policies.json" "/Applications/LibreWolf.app/Contents/Resources/distribution/policies.json"
}

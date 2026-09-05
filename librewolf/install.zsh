phase_1_admin_installs() {
  local url latest_version installed_version tmp_dir dmg_path mount_point app_path expected_sha256 actual_sha256 needs_install=1

  url="$(curl -fsSL --compressed https://librewolf.net/installation/macos/ | grep -Eo 'https://dl\.librewolf\.net/librewolf/[^"]*macos-arm64-package\.dmg' | head -n 1)"
  [[ -n "$url" ]] || {
    echo "Could not find latest LibreWolf arm64 DMG."
    return 1
  }
  latest_version="${${${url:t}#librewolf-}%-macos-arm64-package.dmg}"

  if [[ -x /Applications/LibreWolf.app/Contents/MacOS/librewolf ]]; then
    installed_version="$(/Applications/LibreWolf.app/Contents/MacOS/librewolf --version | awk '{print $NF}')"
    [[ "$installed_version" == "$latest_version" ]] && needs_install=0
  fi

  if ((needs_install)); then
    tmp_dir="$(mktemp -d)"
    dmg_path="$tmp_dir/LibreWolf.dmg"
    mount_point="$tmp_dir/mount"
    app_path="$tmp_dir/LibreWolf.app"
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
    ditto "$mount_point/LibreWolf.app" "$app_path"
    mkdir -p "$app_path/Contents/Resources/distribution"
    cp -p librewolf/policies.json \
      "$app_path/Contents/Resources/distribution/policies.json"
    # The policy file changes the vendor-sealed bundle, so give the local copy
    # a valid ad-hoc signature before installing it.
    codesign --force --deep --sign - "$app_path"
    codesign --verify --deep --strict "$app_path"
    rm -rf /Applications/LibreWolf.app
    ditto "$app_path" /Applications/LibreWolf.app
    hdiutil detach "$mount_point"
    xattr -dr com.apple.quarantine /Applications/LibreWolf.app
    rm -rf "$tmp_dir"
  fi

}

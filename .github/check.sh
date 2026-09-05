#!/bin/sh

set -eu

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

for command_name in git shfmt shellcheck; do
  command -v "$command_name" > /dev/null 2>&1 || {
    echo "Missing required command: $command_name" >&2
    exit 127
  }
done

zsh_files=$(mktemp)
bash_files=$(mktemp)
sh_files=$(mktemp)
trap 'rm -f "$zsh_files" "$bash_files" "$sh_files"' EXIT HUP INT TERM

while IFS= read -r file; do
  [ -f "$file" ] || continue
  first_line=$(head -n 1 "$file" 2> /dev/null | LC_ALL=C tr -d '\000' || true)

  case "$file" in
    *.zsh | */.zshrc.d/* | */.zshenv.d/*) printf '%s\0' "$file" >> "$zsh_files" ;;
  esac

  case "$first_line" in
    '#!/bin/zsh'* | '#!/usr/bin/env zsh'*) printf '%s\0' "$file" >> "$zsh_files" ;;
  esac

  case "$first_line" in
    '#!/bin/bash'* | '#!/usr/bin/env bash'*) printf '%s\0' "$file" >> "$bash_files" ;;
    *)
      case "$file:$first_line" in
        *.sh:* | *:'#!/bin/sh'* | *:'#!/usr/bin/env sh'* | *:'#!/bin/ash'* | *:'#!/usr/bin/env ash'*)
          printf '%s\0' "$file" >> "$sh_files"
          ;;
      esac
      ;;
  esac
done << EOF
$(git ls-files)
EOF

if [ -s "$zsh_files" ]; then
  xargs -0 shfmt -ln zsh -i 2 -ci -sr -d < "$zsh_files"
else
  echo "No zsh files found."
fi

if [ -s "$bash_files" ]; then
  xargs -0 shfmt -ln bash -i 2 -ci -sr -d < "$bash_files"
  xargs -0 shellcheck -s bash < "$bash_files"
else
  echo "No bash-shebang files found."
fi

if [ -s "$sh_files" ]; then
  xargs -0 shfmt -ln posix -i 2 -ci -sr -d < "$sh_files"
  xargs -0 shellcheck -s sh < "$sh_files"
else
  echo "No POSIX sh/ash files found."
fi

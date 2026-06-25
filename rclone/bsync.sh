rcloneclean() {
  if [ -z "$1" ]; then
    printf '%s\n' "Usage: rcloneclean <remote:path/>"
    return 1
  fi

  if ! command -v rclone >/dev/null 2>&1; then
    printf '%s\n' "rclone not found"
    return 1
  fi

  command rclone delete "$1" \
    --include ".DS_Store" \
    --include "._*" \
    --include "Thumbs.db" \
    --include "desktop.ini" \
    --include ".Spotlight-V100/**" \
    --include ".Trashes/**" \
    --include ".fseventsd/**" \
    --include ".TemporaryItems/**" \
    --include '$RECYCLE.BIN/**' \
    --include "System Volume Information/**" \
    -v
}

_bsync_confirm() {
  printf '%s (y/n): ' "$1"
  IFS= read -r _bsync_reply
  [ "$_bsync_reply" = "y" ]
}

_bsync_run() {
  _bsync_run_local_path="$1"
  _bsync_run_remote_path="$2"
  shift 2

  command rclone bisync "$_bsync_run_local_path" "$_bsync_run_remote_path" \
    --check-access \
    --max-delete 20 \
    --conflict-resolve newer \
    --exclude ".DS_Store" \
    --exclude "._*" \
    --exclude ".Spotlight-V100" \
    --exclude ".Trashes" \
    --exclude ".fseventsd" \
    --exclude ".TemporaryItems" \
    --exclude "Thumbs.db" \
    --exclude "desktop.ini" \
    --exclude '$RECYCLE.BIN' \
    --exclude "System Volume Information" \
    -v \
    "$@"
}

_bsync_count_matches() {
  printf '%s\n' "$1" | grep -E -c "$2" 2>/dev/null || true
}

bsync() {
  _bsync_resync=0
  if [ "${1:-}" = "--resync" ]; then
    _bsync_resync=1
    shift
  fi

  _bsync_local_path="${1:-}"
  _bsync_remote_path="${2:-}"

  if [ -z "$_bsync_local_path" ] || [ -z "$_bsync_remote_path" ]; then
    printf '%s\n' "Usage: bsync [--resync] <local-path> <remote:path>"
    return 1
  fi

  # Preflight
  if ! command -v rclone >/dev/null 2>&1; then
    printf '%s\n' "rclone not found"
    return 1
  fi

  if [ ! -d "$_bsync_local_path" ]; then
    printf '%s\n' "Local path missing: $_bsync_local_path"
    return 1
  fi

  if ! command rclone lsd "$_bsync_remote_path" >/dev/null 2>&1; then
    printf '%s\n' "Remote not accessible: $_bsync_remote_path"
    return 1
  fi

  # Ensure access sentinel exists on BOTH sides (required for --check-access)
  if [ ! -f "$_bsync_local_path/RCLONE_TEST" ]; then
    printf '%s\n' "Creating RCLONE_TEST locally..."
    printf '%s\n' "rclone bisync access check" > "$_bsync_local_path/RCLONE_TEST"
  fi

  # Copy it to remote if it doesn't exist there
  if ! command rclone lsf "$_bsync_remote_path" | grep -q "^RCLONE_TEST$"; then
    printf '%s\n' "Creating RCLONE_TEST on remote..."
    command rclone copyto "$_bsync_local_path/RCLONE_TEST" "$_bsync_remote_path/RCLONE_TEST"
  fi

  if [ "$_bsync_resync" -eq 1 ]; then
    printf '%s\n' "=== Resync dry-run ==="
    _bsync_run "$_bsync_local_path" "$_bsync_remote_path" --resync --dry-run || return 1
    _bsync_confirm "Run actual resync?" || { printf '%s\n' "Cancelled."; return 0; }
    printf '%s\n' "=== Resyncing ==="
    if _bsync_run "$_bsync_local_path" "$_bsync_remote_path" --resync; then
      printf '%s\n' "Done. Use 'bsync' from now on."
    else
      printf '%s\n' "ERROR."
      return 1
    fi
    return 0
  fi

  # Normal sync: dry-run, summarise, confirm
  printf '%s\n' "=== Dry-run: $_bsync_local_path <-> $_bsync_remote_path ==="
  _bsync_output="$(_bsync_run "$_bsync_local_path" "$_bsync_remote_path" --dry-run 2>&1)"
  _bsync_status=$?
  printf '%s\n' "$_bsync_output"

  printf '\n%s\n' "--- Summary ---"
  printf '%s\n' "Copy  -> remote : $(_bsync_count_matches "$_bsync_output" "COPY.*$_bsync_remote_path")"
  printf '%s\n' "Copy  -> local  : $(_bsync_count_matches "$_bsync_output" "COPY.*$_bsync_local_path")"
  printf '%s\n' "Delete (remote): $(_bsync_count_matches "$_bsync_output" "DELETE.*$_bsync_remote_path")"
  printf '%s\n' "Delete (local) : $(_bsync_count_matches "$_bsync_output" "DELETE.*$_bsync_local_path")"
  _bsync_conflicts="$(_bsync_count_matches "$_bsync_output" "conflict|CONFLICT")"
  if [ "$_bsync_conflicts" -gt 0 ]; then
    printf '%s\n' "Conflicts      : $_bsync_conflicts (keeping newer)"
  fi

  if [ "$_bsync_status" -ne 0 ]; then
    printf '%s\n' "Dry-run failed (exit $_bsync_status). First run? Try: bsync --resync"
    return "$_bsync_status"
  fi

  if printf '%s\n' "$_bsync_output" | grep -E -q "up to date|No changes|0 changes"; then
    printf '%s\n' "Already in sync."
    return 0
  fi

  printf '\n'
  _bsync_confirm "Proceed with sync?" || { printf '%s\n' "Cancelled."; return 0; }
  printf '%s\n' "=== Syncing ==="
  if _bsync_run "$_bsync_local_path" "$_bsync_remote_path"; then
    printf '%s\n' "Done."
  else
    printf '%s\n' "ERROR."
    return 1
  fi
}

_rclone_remote_dir_name() {
  _rclone_remote_dir_name_result=${1%/}
  _rclone_remote_dir_name_result=${_rclone_remote_dir_name_result##*/}
  [ -n "$_rclone_remote_dir_name_result" ] || _rclone_remote_dir_name_result=remote
}

_rclone_copy_remote_dir_to_tmp() {
  _rclone_remote_dir_local="$1"
  _rclone_remote_dir_remote="$2"
  _rclone_remote_dir_tmp_prefix="$3"

  if [ ! -d "$_rclone_remote_dir_local" ]; then
    printf '%s\n' "Local path missing: $_rclone_remote_dir_local" >&2
    return 1
  fi

  command -v rclone >/dev/null 2>&1 || { printf '%s\n' "rclone not found" >&2; return 1; }
  _rclone_remote_dir_name "$_rclone_remote_dir_local"
  _rclone_remote_dir_tmp=$(mktemp -d "${TMPDIR:-/tmp}/${_rclone_remote_dir_tmp_prefix}.XXXXXX") || return 1
  _rclone_remote_dir_copy="$_rclone_remote_dir_tmp/$_rclone_remote_dir_name_result"
  mkdir -p "$_rclone_remote_dir_copy" || { rm -rf "$_rclone_remote_dir_tmp"; return 1; }

  if command rclone copy "$_rclone_remote_dir_remote" "$_rclone_remote_dir_copy"; then
    :
  else
    _rclone_remote_dir_status=$?
    rm -rf "$_rclone_remote_dir_tmp"
    return "$_rclone_remote_dir_status"
  fi

  return 0
}

rclonedirdiff() {
  if [ "$#" -ne 2 ]; then
    printf '%s\n' "Usage: rclonedirdiff <local-path> <remote:path>"
    return 1
  fi

  command -v diff >/dev/null 2>&1 || { printf '%s\n' "diff not found" >&2; return 1; }
  _rclone_copy_remote_dir_to_tmp "$1" "$2" rclone-dirdiff || return $?

  if command diff -ruN "$1" "$_rclone_remote_dir_copy"; then
    _rclone_dirdiff_status=0
  else
    _rclone_dirdiff_status=$?
  fi

  rm -rf "$_rclone_remote_dir_tmp"
  return "$_rclone_dirdiff_status"
}

_rclone_vim_single_quote() {
  printf '%s' "$1" | sed "s/'/''/g"
}

rclonevimdirdiff() {
  if [ "$#" -ne 2 ]; then
    printf '%s\n' "Usage: rclonevimdirdiff <local-path> <remote:path>"
    return 1
  fi

  command -v vim >/dev/null 2>&1 || { printf '%s\n' "vim not found" >&2; return 1; }
  _rclone_copy_remote_dir_to_tmp "$1" "$2" rclone-vimdirdiff || return $?

  _rclone_vimdirdiff_local=$(_rclone_vim_single_quote "$1")
  _rclone_vimdirdiff_remote=$(_rclone_vim_single_quote "$_rclone_remote_dir_copy")
  if command vim -c "execute 'DirDiff ' . fnameescape('$_rclone_vimdirdiff_local') . ' ' . fnameescape('$_rclone_vimdirdiff_remote')"; then
    _rclone_vimdirdiff_status=0
  else
    _rclone_vimdirdiff_status=$?
  fi

  rm -rf "$_rclone_remote_dir_tmp"
  return "$_rclone_vimdirdiff_status"
}

alias rclone='rclone -v -P'

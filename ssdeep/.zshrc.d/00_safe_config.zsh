# Find similar (near-duplicate) files using fuzzy hashing
# Usage: dupsim <directory> <sensitivity 0-100>
dupsim() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: dupsim <directory> <sensitivity>"
    echo "  Example: dupsim ~/Documents 70"
    echo "  Sensitivity: 0 (low, many matches) to 100 (high, near-identical only)"
    return 1
  fi
  find "$1" -type f -print0 | xargs -0 ssdeep -pl -t "$2"
}

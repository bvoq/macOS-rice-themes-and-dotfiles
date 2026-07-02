# return early for non-interactive/dumb/non-tty cases; terminal repair like stty sane
# This runs inside the .zshrc source loop, so a bare `return` only ends this
# fragment. Raise RAZORDOT_STOP instead; the loop breaks on it and skips the
# remaining (20/30/40) fragments, just like the old inline early-return did.
if ! [[ -o interactive ]] || ! [[ -t 0 ]] || [[ "$TERM" == dumb ]]; then
  RAZORDOT_STOP=1
  return
fi

# make sure that enter key works: https://askubuntu.com/questions/441744/pressing-enter-produces-m-instead-of-a-newline
stty sane

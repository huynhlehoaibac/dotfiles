#!/usr/bin/env bash
#
# Dotfiles clean (remove backups left by install.sh).
#
# install.sh backs up any existing ~ target to "<name>.bak.<timestamp>" before
# overwriting it. Those backups pile up over time. This script finds and removes
# them for the whitelisted entries only.
#
# Usage (from Git Bash):
#   ./clean.sh            # show what WOULD be deleted, then ask to confirm
#
# Safety:
#   - Shows a dry-run preview first, then asks for confirmation before deleting.
#     Nothing is deleted unless you answer "y" at the prompt.
#   - Only matches "<managed-name>.bak.*" next to each whitelisted entry in ~.
#     It never touches your real config or unrelated files.

set -euo pipefail

HOME_UNIX="$HOME"
APPLY="0"

# ---- Whitelist: keep identical to adopt.sh / install.sh. "rel/path|type" ----
ENTRIES=(
  ".bashrc|file"
  ".config/mise|dir"
  ".config/wezterm|dir"
  ".config/starship.toml|file"
  ".oh-my-bash/custom/plugins|dir"
)
# -----------------------------------------------------------------------------

# Walk the whitelist and act on each matching backup. In preview mode it only
# lists them; with APPLY=1 it deletes. Returns success either way; sets the
# global `found` to 1 when at least one backup matched.
clean() {
  found=0
  for e in "${ENTRIES[@]}"; do
    name="${e%%|*}"
    # Backups sit beside the target: ~/<name>.bak.<timestamp>
    for bak in "$HOME_UNIX/$name".bak.*; do
      [ -e "$bak" ] || continue        # no matches -> skip the literal glob
      found=1
      if [ "$APPLY" = "1" ]; then
        rm -rf "$bak"
        echo "removed: $bak"
      else
        echo "would remove: $bak"
      fi
    done
  done
}

echo "home:   $HOME_UNIX"
echo
echo "Preview (dry run) — nothing has been deleted yet:"
echo

clean

if [ "$found" = "0" ]; then
  echo "no backup files found"
  echo
  echo "done"
  exit 0
fi

echo
printf "Delete these backup files? [y/N] "
read -r reply
case "$reply" in
  [yY]|[yY][eE][sS]) APPLY="1" ;;
  *) echo "aborted. nothing was deleted."; exit 0 ;;
esac

echo
echo "Deleting..."
echo

clean

echo
echo "done"

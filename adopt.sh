#!/usr/bin/env bash
#
# Dotfiles adopt (copy real config FROM ~ INTO this repo).
#
# Run this on the machine that has your real config. It copies each whitelisted
# file/dir from ~ into the repo (same relative path), so git can track it.
# Then commit + push to back it up.
#
# This uses plain COPY (no symlinks), so it needs no admin/Developer Mode.
# Tradeoff: the repo and your live files are separate copies and can drift.
# Re-run this whenever you change a config in ~ and want to capture it.
#
# Usage (from Git Bash):
#   ./adopt.sh            # show what WOULD be copied, then ask to confirm
#
# Safety:
#   - Shows a dry-run preview first, then asks for confirmation before writing.
#     Nothing is written unless you answer "y" at the prompt.
#   - Overwrites the repo copy with the ~ version (repo mirrors ~).

set -euo pipefail

REPO_UNIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_UNIX="$HOME"
APPLY="0"

# ---- Whitelist: keep identical to install.sh. "rel/path|type" (file|dir) ----
ENTRIES=(
  ".bashrc|file"
  ".config/mise|dir"
  ".config/wezterm|dir"
  ".config/starship.toml|file"
  ".oh-my-bash/custom/plugins|dir"
)
# Note: .config/scoop is intentionally excluded (machine-specific state).
# -----------------------------------------------------------------------------

adopt() {
  local name="$1" type="$2"
  local src="$HOME_UNIX/$name"      # real file in ~
  local dst="$REPO_UNIX/$name"      # copy destination in repo

  if [ ! -e "$src" ]; then
    echo "skip (not found in ~): ~/$name"; return
  fi

  if [ "$APPLY" != "1" ]; then
    echo "would copy ($type): ~/$name  ->  repo/$name"; return
  fi

  mkdir -p "$(dirname "$dst")"
  if [ "$type" = "dir" ]; then
    rm -rf "$dst"
    cp -R "$src" "$dst"
  else
    cp -f "$src" "$dst"
  fi
  echo "copied ($type): ~/$name  ->  repo/$name"
}

echo "repo:   $REPO_UNIX"
echo "home:   $HOME_UNIX"
echo
echo "Preview (dry run) — nothing has been written yet:"
echo

for e in "${ENTRIES[@]}"; do
  adopt "${e%%|*}" "${e##*|}"
done

echo
printf "Apply these changes and copy ~ -> repo ? [y/N] "
read -r reply
case "$reply" in
  [yY]|[yY][eE][sS]) APPLY="1" ;;
  *) echo "aborted. nothing was written."; exit 0 ;;
esac

echo
echo "Applying..."
echo

for e in "${ENTRIES[@]}"; do
  adopt "${e%%|*}" "${e##*|}"
done

echo
echo "done"

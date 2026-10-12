#!/usr/bin/env bash
#
# Dotfiles install (copy config FROM this repo OUT to ~).
#
# Run this on a new machine after cloning the repo. It copies each whitelisted
# file/dir from the repo to its ~ location, so your config is in place.
#
# This uses plain COPY (no symlinks), so it needs no admin/Developer Mode.
# Tradeoff: repo and ~ are separate copies. After editing config in ~, run
# adopt.sh to pull changes back into the repo before committing.
#
# Usage (from Git Bash):
#   ./install.sh            # show what WOULD be copied (dry run)
#   APPLY=1 ./install.sh    # actually copy repo -> ~
#
# Safety:
#   - Dry run by default. Nothing is written until APPLY=1.
#   - If a target already exists in ~, it is backed up to <name>.bak.<timestamp>
#     before being overwritten (never silently clobbered).

set -euo pipefail

REPO_UNIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_UNIX="$HOME"
APPLY="${APPLY:-0}"
STAMP="$(date +%Y%m%d-%H%M%S)"

# ---- Whitelist: keep identical to adopt.sh. "rel/path|type" (file|dir) ----
ENTRIES=(
  ".bashrc|file"
  ".config/mise|dir"
  ".config/wezterm|dir"
  ".config/starship.toml|file"
  ".oh-my-bash/custom/plugins|dir"
)
# ---------------------------------------------------------------------------

install() {
  local name="$1" type="$2"
  local src="$REPO_UNIX/$name"      # repo copy
  local dst="$HOME_UNIX/$name"      # destination in ~

  if [ ! -e "$src" ]; then
    echo "skip (not in repo): $name"; return
  fi

  if [ "$APPLY" != "1" ]; then
    if [ -e "$dst" ]; then
      echo "would copy ($type): repo/$name  ->  ~/$name   (existing ~ copy backed up)"
    else
      echo "would copy ($type): repo/$name  ->  ~/$name"
    fi
    return
  fi

  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    mv "$dst" "$dst.bak.$STAMP"
    echo "backed up existing: ~/$name -> ~/$name.bak.$STAMP"
  fi
  if [ "$type" = "dir" ]; then
    cp -R "$src" "$dst"
  else
    cp -f "$src" "$dst"
  fi
  echo "installed ($type): repo/$name  ->  ~/$name"
}

echo "repo:   $REPO_UNIX"
echo "home:   $HOME_UNIX"
echo
echo "Preview (dry run) — nothing has been written yet:"
echo

for e in "${ENTRIES[@]}"; do
  install "${e%%|*}" "${e##*|}"
done

echo
printf "Apply these changes and copy repo -> ~ ? [y/N] "
read -r reply
case "$reply" in
  [yY]|[yY][eE][sS]) APPLY="1" ;;
  *) echo "aborted. nothing was written."; exit 0 ;;
esac

echo
echo "Applying..."
echo

for e in "${ENTRIES[@]}"; do
  install "${e%%|*}" "${e##*|}"
done

echo
echo "done"

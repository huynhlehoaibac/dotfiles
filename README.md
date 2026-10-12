# dotfiles

Personal configuration files, version-controlled and portable across machines.

This repo is the backup/source of truth for a selected set of config files. It
uses a **copy-based** workflow (not symlinks), so it needs no admin rights or
Windows Developer Mode — just Git Bash.

## What's tracked

| Path | Type | Notes |
|---|---|---|
| `.bashrc` | file | Bash startup file |
| `.config/mise` | dir | mise (runtime/version manager) config |
| `.config/wezterm` | dir | WezTerm terminal config |
| `.config/starship.toml` | file | Starship prompt config |
| `.oh-my-bash/custom/plugins` | dir | Oh My Bash custom plugins |

`.config/scoop` is intentionally **not** tracked — it is machine-specific state.

The set is defined once in the `ENTRIES` list, kept identical in both
`adopt.sh` and `install.sh`. To track more, add a line (`"rel/path|type"`,
where `type` is `file` or `dir`) to that list in **both** scripts.

## How it works

Real files live in two independent places: your home directory (`~`) where apps
read them, and this repo where git tracks them. The two scripts copy between
them in opposite directions:

```
adopt.sh      ~  ──copy──▶  repo      (capture current config, then push)
install.sh    repo ──copy──▶  ~       (lay config down on a new machine)
```

Because these are copies, the two sides can **drift**. After you change a config
in `~`, re-run `adopt.sh` to pull the change back into the repo before
committing.

## Capture current config into the repo

Run on the machine that has your real config.

```bash
cd ~/dev/pa/dotfiles

./adopt.sh            # dry run — shows what WOULD be copied, writes nothing
APPLY=1 ./adopt.sh    # actually copy ~ -> repo
```

Then commit and push:

```bash
git add -A
git commit -m "Update dotfiles"
git push
```

## Set up a new machine

```bash
git clone git@github.com:huynhlehoaibac/dotfiles.git ~/dev/pa/dotfiles
cd ~/dev/pa/dotfiles

./install.sh            # dry run — shows what WOULD be copied, writes nothing
APPLY=1 ./install.sh    # actually copy repo -> ~
```

If a target already exists in `~`, `install.sh` backs it up to
`<name>.bak.<timestamp>` before overwriting, so nothing is silently lost.

## Clean up backups

`install.sh` leaves `<name>.bak.<timestamp>` files in `~` each time it
overwrites an existing config. Remove them with:

```bash
cd ~/dev/pa/dotfiles

./clean.sh            # dry run — lists backups that WOULD be removed
APPLY=1 ./clean.sh    # actually delete them
```

It only targets `*.bak.*` files next to the whitelisted entries, so it never
touches your real config or unrelated files.

## Scripts

| Script | Direction | Default | Apply |
|---|---|---|---|
| `adopt.sh` | `~` → repo | dry run | `APPLY=1 ./adopt.sh` |
| `install.sh` | repo → `~` | dry run | `APPLY=1 ./install.sh` |
| `clean.sh` | removes `~/*.bak.*` | dry run | `APPLY=1 ./clean.sh` |

Both are dry-run unless `APPLY=1` is set **inline** (not via `&&`):

```bash
APPLY=1 ./adopt.sh      # correct — variable passed to the script
APPLY=1 && ./adopt.sh   # WRONG — runs as two commands, script sees APPLY=0
```

## Notes

- Run from **Git Bash**. The scripts derive the repo path from their own
  location and `~` from `$HOME`, so they work for any user/machine.
- Nothing here requires admin or Developer Mode.
- Keep secrets out of this repo (SSH private keys, tokens, credentials). Only
  the configs listed above are tracked.

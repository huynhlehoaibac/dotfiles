# Fix Oh My Bash line overlapping / broken wrapping by forcing UTF-8
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

eval "$(zoxide init bash)"
__zoxide_pwd() {
    command cygpath -w "$(builtin pwd -L)"
}

#starship need java to show current version, so mise need to fully load before it.


#! bash oh-my-bash.module

# Check if mise is installed
if _omb_util_command_exists mise; then
  eval -- "$(mise activate bash)"
else
  _omb_util_print '[oh-my-bash] mise not found, please install it from https://github.com/jdx/mise' >&2
fi

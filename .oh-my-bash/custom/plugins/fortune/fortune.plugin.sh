#! bash oh-my-bash.module

function fortune {
    # Directory of this script, resolved regardless of the caller's cwd.
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local file="$script_dir/fortune.txt"

    # Bail out if the file is missing
    if [[ ! -f "$file" ]]; then
        echo "Fortune file not found: $file" >&2
        return 1
    fi

    # Single pass: record separator is a "%"-only line, tolerant of CRLF or LF.
    # Reservoir sampling keeps one random block without a second read.
    awk -v RS='\r?\n%\r?\n' -v seed="$RANDOM" '
        BEGIN { srand(seed) }
        NF {
            n++
            # Replace the kept block with this one with probability 1/n.
            if (int(rand() * n) == 0) { chosen = $0 }
        }
        END {
            if (n == 0) {
                print "No fortunes found" > "/dev/stderr"
                exit 1
            }
            gsub(/\r/, "", chosen)
            printf "%s\n", chosen
        }
    ' "$file"
}

fortune | cowsay --aurora

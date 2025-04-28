#!/bin/bash

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <search_string> <file>

Options:
  -i              Case insensitive search (default)
  -n              Show line numbers
  -v              Invert match (select non-matching lines)
  -h, --help      Show this help message and exit

Examples:
  $0 -nv "pattern" file.txt    # Show non-matching lines with numbers
  $0 "search term" data.txt   # Case insensitive search
EOF
}

# Initialize options
show_line_numbers=0
invert_match=0
case_insensitive=1

# Use getopts for option parsing
while getopts ":invh-:" opt; do
    case $opt in
        i) case_insensitive=1 ;;
        n) show_line_numbers=1 ;;
        v) invert_match=1 ;;
        h) usage; exit 0 ;;
        -) # Handle long options
            case "${OPTARG}" in
                help) usage; exit 0 ;;
                *) echo "Unknown option --${OPTARG}" >&2; usage; exit 1 ;;
            esac ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
    esac
done
shift $((OPTIND -1))

# Check remaining arguments
if [ $# -lt 2 ]; then
    if [ $# -eq 0 ]; then
        echo "Error: missing both search string and file" >&2
    elif [ -f "$1" ]; then
        echo "Error: missing search string (you provided only a file)" >&2
    else
        echo "Error: missing file" >&2
    fi
    usage >&2
    exit 1
fi

# Build grep command
grep_command="grep"
if [ $case_insensitive -eq 1 ]; then
    grep_command+=" -i"
fi
if [ $show_line_numbers -eq 1 ]; then
    grep_command+=" -n"
fi
if [ $invert_match -eq 1 ]; then
    grep_command+=" -v"
fi

search_string="$1"
file="$2"

# Verify file exists
if [ ! -f "$file" ]; then
    echo "File not found: $file" >&2
    exit 1
fi

# Execute grep
eval "$grep_command -- \"$search_string\" \"$file\""
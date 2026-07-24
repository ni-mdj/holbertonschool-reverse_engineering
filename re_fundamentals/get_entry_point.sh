#!/bin/bash

# Vérifie qu'un seul argument a été fourni.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ELF_file>" >&2
    exit 1
fi

file_name="$1"

# Recherche messages.sh dans le même dossier que le script.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
messages_file="$script_dir/messages.sh"

if [ ! -f "$messages_file" ]; then
    echo "Error: messages.sh not found." >&2
    exit 1
fi

source "$messages_file"

# Vérifie que le fichier existe.
if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist." >&2
    exit 1
fi

# Vérifie que la commande readelf est disponible.
if ! command -v readelf >/dev/null 2>&1; then
    echo "Error: readelf command not found." >&2
    exit 1
fi

# Vérifie que le fichier est bien un fichier ELF.
if ! readelf -h "$file_name" >/dev/null 2>&1; then
    echo "Error: File '$file_name' is not a valid ELF file." >&2
    exit 1
fi

elf_header="$(readelf -h "$file_name")"

magic_number="$(
    printf '%s\n' "$elf_header" |
    awk -F: '/^[[:space:]]*Magic:/ {
        sub(/^[[:space:]]+/, "", $2)
        print $2
        exit
    }'
)"

class="$(
    printf '%s\n' "$elf_header" |
    awk -F: '/^[[:space:]]*Class:/ {
        sub(/^[[:space:]]+/, "", $2)
        print $2
        exit
    }'
)"

byte_order="$(
    printf '%s\n' "$elf_header" |
    awk -F: '/^[[:space:]]*Data:/ {
        sub(/^[[:space:]]+/, "", $2)
        print $2
        exit
    }'
)"

entry_point_address="$(
    printf '%s\n' "$elf_header" |
    awk -F: '/^[[:space:]]*Entry point address:/ {
        sub(/^[[:space:]]+/, "", $2)
        print $2
        exit
    }'
)"

display_elf_header_info
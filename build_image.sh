#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir="$repo_root/build"
image="$build_dir/is.raw"

mkdir -p "$build_dir"

as --32 -o "$build_dir/boot.o" "$repo_root/boot/boot.S"
ld -m elf_i386 -T "$repo_root/boot/boot.ld" -o "$image" "$build_dir/boot.o"
rm -f "$build_dir/boot.o"

bytes=$(wc -c < "$image" | tr -d '[:space:]')
if [ "$bytes" != 512 ]; then
    printf 'image build failed: expected 512 bytes, got %s\n' "$bytes" >&2
    exit 1
fi

signature=$(od -An -tx1 -j 510 -N 2 "$image" | tr -d '[:space:]')
if [ "$signature" != 55aa ]; then
    printf 'image build failed: expected boot signature 55aa, got %s\n' "$signature" >&2
    exit 1
fi

printf '%s\n' "$image"

#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
marker=IS_BOOT_OK

not_verified() {
    printf 'NOT_VERIFIED qemu_boot reason=%s\n' "$1"
    exit 2
}

fail() {
    printf 'FAIL qemu_boot reason=%s\n' "$1"
    exit 1
}

for command_name in as ld wc tr od sha256sum timeout grep mktemp qemu-system-x86_64; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        not_verified "missing_command:$command_name"
    fi
done

if ! image=$(sh "$repo_root/build_image.sh"); then
    fail image_build
fi

sha_before=$(sha256sum "$image")
sha_before=${sha_before%% *}
log=$(mktemp)
trap 'rm -f "$log"' EXIT HUP INT TERM

set +e
timeout 5s qemu-system-x86_64 \
    -machine pc \
    -m 16M \
    -drive "file=$image,format=raw,if=ide" \
    -boot order=c \
    -display none \
    -serial stdio \
    -monitor none \
    -no-reboot \
    >"$log" 2>&1
qemu_exit=$?
set -e

sha_after=$(sha256sum "$image")
sha_after=${sha_after%% *}
if [ "$sha_before" != "$sha_after" ]; then
    fail image_changed_during_boot
fi

if ! grep -Fq "$marker" "$log"; then
    cat "$log" >&2
    fail "marker_not_seen:qemu_exit=$qemu_exit"
fi

printf 'PASS qemu_boot image=%s sha256=%s marker=%s qemu_exit=%s\n' \
    "$image" "$sha_before" "$marker" "$qemu_exit"

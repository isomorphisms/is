# is

Issue #1 starts with one provider-neutral acceptance target: build one bootable RAW disk image and prove that exact image boots under QEMU.

## First acceptance check

Run:

```sh
sh accept/qemu_boot.sh
```

The check builds `build/is.raw`, verifies that it is exactly 512 bytes with the BIOS boot signature `55 aa`, records its SHA-256, hands that same file to QEMU as the boot disk, checks the SHA-256 again afterward, and waits for the disk to emit `IS_BOOT_OK` on COM1.

Receipt meanings:

- `PASS` — QEMU booted the exact hashed RAW image, the serial marker was observed, and the image hash was unchanged afterward.
- `FAIL` — the image could not be built/validated, changed during the check, or did not emit the marker.
- `NOT_VERIFIED` — a required local command is missing, so no boot claim is made.

This first image is deliberately an x86 BIOS boot proof. “Provider-neutral” here means that the artifact and acceptance check contain no Hetzner, AWS, or other cloud-provider integration.

This receipt does **not** establish Hetzner import/deployment, networking, a usable cloud console, UEFI boot, QCOW2 support, or AWS support. Those are later acceptance steps.

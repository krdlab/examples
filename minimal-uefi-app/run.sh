#!/bin/bash
set -eu

cp /usr/share/OVMF/OVMF_CODE.fd ./
cp /usr/share/OVMF/OVMF_VARS.fd ./

mkdir -p vm/efi/boot; :
cp target/x86_64-unknown-uefi/debug/minimal-uefi-app.efi ./vm/efi/boot/bootx64.efi

qemu-system-x86_64 \
    -drive if=pflash,format=raw,readonly=on,file=OVMF_CODE.fd \
    -drive if=pflash,format=raw,readonly=on,file=OVMF_VARS.fd \
    -drive format=raw,file=fat:rw:vm \
    -nographic -serial mon:stdio

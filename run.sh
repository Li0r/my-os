#!/bin/bash
set -e
cd "$(dirname "$0")"
export PATH="$HOME/opt/cross/bin:$PATH"

# --- bootloader ---
nasm -f bin boot/boot.asm -o boot/boot.bin

# --- kernel ---
i686-elf-gcc kernel.c -o kernel.o -ffreestanding -Wall -Wextra -c
nasm -f elf32 kernel_entry.asm -o kernel_entry.o
i686-elf-ld -T linker.ld -o kernel.bin kernel_entry.o kernel.o

# --- stage 2 ---
SECTORS=$(( ($(stat -c %s kernel.bin) + 511) / 512 ))
nasm -f bin -DKERNEL_SECTORS=$SECTORS boot/stage2.asm -o boot/stage2.bin

# --- disk image ---
rm -f disk.img
dd if=/dev/zero of=disk.img bs=512 count=64
dd if=boot/boot.bin of=disk.img conv=notrunc
dd if=boot/stage2.bin of=disk.img bs=512 seek=1 conv=notrunc
dd if=kernel.bin of=disk.img bs=512 seek=2 conv=notrunc

# --- run ---
qemu-system-x86_64 -drive format=raw,file=disk.img -no-reboot -no-shutdown

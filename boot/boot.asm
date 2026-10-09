[org 0x7c00]
BITS 16

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00
mov [drive_num], dl			; in case we want to boot from other places then the BIOS puts the real drive number in dl

mov si, msg
mov bx, 0x7e00


mov ah, 0x2
mov al, 1
mov ch, 0
mov cl, 2
mov dh, 0
mov dl, [drive_num]
int 0x13

jc error
jmp 0x0000:0x7e00
error:
    mov ah, 0xe
    mov al, [si]
    cmp al, 0
    je done
    int 0x10
    inc si
    jmp error

done:  
    jmp $

msg:
    db "[!] disk_error [!]", 0

drive_num: 
    db 0				; store the drive number

times 510-($-$$) db 0
dw 0xAA55


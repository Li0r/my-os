[org 0x7e00]
[BITS 16]



CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

mov [drive_num], dl

in al, 0x92			; we read from port 0x92 (System Control A) current state.
test al, 2			; check if Bit 1 (value 2, the A20 bit) is already on
jnz a20_enabled
or al, 2			; force bit 1 (value 2, the A20 bit) to turn on.
and al, 0xfe			; force Bit 0 (value 1, the reset bit) to turn off.
out 0x92, al                    ; put it back the modifyed state to port 0x92.
a20_enabled:

mov ax, 0x1000
mov es, ax
xor bx, bx

mov ah, 0x2
mov al, KERNEL_SECTORS
mov ch, 0
mov cl, 3
mov dh, 0
mov dl, [drive_num]
int 0x13			; reads the kernel.bin to memory 0x10000
jc kernel_load_error

cli  				; disable interupts
lgdt [gdt_ptr]			; load the GDT descriptor
    
mov eax, cr0
or eax, 1			; enable "protected mode"
mov cr0, eax
    
jmp CODE_SEG:startProtectedMode ; loading cs with CODE_SEG (gdt_code) + jmp to startProtectedMode = far jump, since we go to 32 bit from 16 bit


gdt_start: 

gdt_null:			;8 bytes
    dq 0

gdt_code:			;8 bytes
    dw 0xffff    		;[LIMIT]: (0-15) 
    dw 0         		;[BASE]: (0-15)
    db 0         		;[BASE]: (16-23)
    db 10011010b 		;[ACCESS-BYTE]: Present, ring 0, code segment (executable), DPL=0, Readable.
    db 11001111b 		;[FLAGS]:32 bit and multiplied by 4KB (we set limit to 4GB) + [LIMIT]:(16-19)
    db 0         		;[BASE]: (24-31) 

gdt_data:			; 8 bytes
    dw 0xffff    		;[LIMIT]: (0-15) : 
    dw 0         		;[BASE]: (0-15)
    db 0         		;[BASE]: (16-23)
    db 10010010b 		;[ACCESS-BYTE]: Present, ring 0, data segment, DPL=0, Writeable.
    db 11001111b 		;[FLAGS]:32 bit and multiplied by 4KB (we set limit to 4GB) + [LIMIT]:(16-19)
    db 0             		;[BASE]: (24-31) 

gdt_end:

gdt_ptr:
    dw gdt_end - gdt_start -1	; limit - size of GDT.
    dd gdt_start           	; base - GDT's memory address.
    

kernel_load_error:
    mov ah, 0xe
    mov al, [si]
    cmp al, 0
    je loop_done
    int 0x10
    inc si
    jmp kernel_load_error

loop_done:
    jmp $

msg:
    db "[!] KERNEL LOAD ERROR [!]",0

drive_num: 
    db 0				; store the drive number


[BITS 32]
startProtectedMode:
    mov ax, DATA_SEG
    mov ds, ax			; loading ds with DATA_SEG (gdt_data) and other register segments.
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax 
    mov esp, 0x90000		; set esp to a free memory in the first MB (filled with different stuff we have to be careful with so this is the free spot for stack).
    
    jmp 0x10000

;===== org means Origin, if not specified, the program will take 0x0000 as start address
org 0x7c00

;===== this BaseOfStack provides intial value for the SP register
BaseOfStack equ 0x7c00

;===== Program start point
Label_Start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BaseOfStack

;==== clear screen
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 0184fh
    int 10h

;==== set focus
    mov ax, 0200h
    mov bx, 0000h
    mov dx, 0000h
    int 10h

;==== display on screen message
    mov ax, 1301h
    mov bx, 000fh
    mov dx, 0000h
    mov cx, 24
    push ax
    mov ax, ds
    mov es, ax
    pop ax
    mov bp, StartBootMessage
    int 10h

;==== reset floppy
    xor ah, ah
    xor dl, dl
    int 13h

    jmp $

StartBootMessage: db "clay boot program start!"

; ==== fill zero until whole sector
    times 510 - ($ - $$) db 0
    dw 0xaa55

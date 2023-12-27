;===== org means Origin, if not specified, the program will take 0x0000 as start address
org 0x7c00

;===== this BaseOfStack provides intial value for the SP register
BaseOfStack             equ 0x7c00
BaseOfLoader            equ 0x1000
OffsetOfLoader          equ 0x00

RootDirSectors          equ 14
SectorNumOfRootDirStart equ 19
SectorNumOfFAT1Start    equ 1
SectorBalance           equ 17

;===== Boot Sector of Fat12 Floppy
jmp short Label_Start
nop
BS_OEMName          db      'TestBoot'
BPB_BytesPerSec     dw      512
BPB_SecPerClus      db      1
BPB_RsvdSecCnt      dw      1
BPB_NumFATs         db      2
BPB_RootEntCnt      dw      224
BPB_TotSec16        dw      2880
BPB_Media           db      0xF0
BPB_FATSz16         dw      9
BPB_SecPerTrk       dw      18
BPB_NumHeads        dw      2
BPB_hiddSec         dd      0
BPB_TotSec32        dd      0
BS_DrvNum          db      0
BS_Reserved1       db      0
BS_BootSig          db      29h
BS_VolID            dd      0
BS_VolLab           db      'boot loader'
BS_FileSysType      db      'FAT12   '
;==== Boot Sector Occupy 62 bytes, the rest will be other code

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

;==== read one sector from floppy
; FUnction Paramaters
; AX : start sector number to be read
; CL : number of sectors to be read
; ES:BX : target address in RAM
; This program will transform LBA format to CHS format for int 13h usage
Func_ReadOneSector:
    push bp
    mov bp, sp
    sub esp, 2
    mov byte [bp - 2], cl
    push bx
    mov bl, [BPB_SecPerTrk]
    div bl
    inc ah
    mov cl, ah ; sector number(bit 0 - 5), cylinder number higher 2 bits (bit 6 - 7)
    mov dh, al
    shr al, 1 ; divided by 2 (Heads Per Cylinder)
    mov ch, al ; cylinder number lower 8 bits
    and dh, 1 ; head number (% operation to get the residual after divided by 2)
    pop bx
    mov dl, [BS_DrvNum]
Label_Go_On_Reading:
    mov ah, 2
    mov al, byte [bp - 2]
    int 13h
    jc Label_Go_On_Reading
    add esp, 2
    pop bp
    ret

StartBootMessage: db "Test boot program start!"

; ==== fill zero until whole sector
    times 510 - ($ - $$) db 0
    dw 0xaa55

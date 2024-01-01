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
DirNuminOneSctor        equ 16

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

;==== display boot message
    mov bx, StartBootMessage
    call print_string

;==== search for LOADER.BIN file
;==== loop from sector 19 to 32, load every sector to 0x7e00
    mov bx, 0x00 ; 0x7e00 offset
    mov ax, 0x7e0 ; 0x7e00 base address, 
    mov es, ax ; 0x7e0 << 16 + 0x00 = 0x7e00

    mov dx, RootDirSectors ; variable for loop control
    mov ax, SectorNumOfRootDirStart - 1
    mov cl, 1 ; read one sector at a time

LoadNextSector:
    inc ax

    ; save registers status before sub function
    push cx
    push ax
    push dx
    push bx
    call Func_ReadOneSector
    call Func_ReadDirEntries
    jc CurrSectorFoundLoaderBin
    ; restore registers status after sub function
    pop bx
    mov ax, 0x7e0 ; base address, 
    mov es, ax ; 0x7e0 << 16 + 0x00 = 0x7e00 is the destination address
    pop dx
    pop ax
    pop cx

    dec dx
    jnz LoadNextSector

CurrSectorFoundLoaderBin:
    add sp, 8 ; restore the stack pointer
    jmp BaseOfLoader:OffsetOfLoader

;==== read one sector from floppy
; FUnction Paramaters
; AX : start sector number to be read
; CL : number of sectors to be read
; ES:BX : target address in RAM
; This program will transform LBA format to CHS format for int 13h usage
Func_ReadOneSector:
    push bp
    mov bp, sp
    sub sp, 2
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
    add sp, 2
    pop bp
    ret

; this function traverse the sector loaded to the 0x7e00
Func_ReadDirEntries:
    mov ax, 0x7e00 - 32
    mov dx, DirNuminOneSctor
LoadNextDir:
    add ax, 32 ; jump 32 bytes a time
    push ax
    push dx
    mov bx, ax
    call Func_CmpLoaderName
    jc FoundLoaderBin
    pop dx
    pop ax

    dec dx
    jnz LoadNextDir

    mov bx, not_found_loader_msg
    call print_string ; no loader.bin found
    ; not found loader.bin!
    clc ; clear carry flag to indicate failure
    ret

FoundLoaderBin:
;    mov bx, found_loader_msg
;    call print_string

    pop dx
    pop ax
    add ax, 26
    mov dx, 0x0000 ; base address
    mov ds, dx
    mov si, ax ; put address to si register
    mov ax, [si] ; First Logical Cluster

    add si, 2
    mov bx, [si]
    add si, 2
    mov cx, [si]

    call Func_LoadLoader

    ; found loader.bin!
    stc ; set carry flag to indicate success
    ret

; use the address of bx register
Func_CmpLoaderName:
    mov dx, 11 ; fixed length of file name
    mov si, loader_name ; se the si to the start point of loader_name
CmpNextChar:
    lodsb ; load 1 byte from si address to al
    cmp al, [bx]
    jne NotFound

    ; move to the next pos
    inc bx
    dec dx
    jnz CmpNextChar

    ; found loader.bin!
    stc ; set carry flag to indicate success
    ret

NotFound:
    ; not found loader.bin!
    clc ; clear carry flag to indicate failure
    ret

; function to load loader.bin to the RAM
; paramaters:
;   ax: First Logical Cluster
;   bx: File Size lower 2 bytes
;   cx: File Size higher 2 bytes
Func_LoadLoader:
    ; save the register value
    push ax
    ; load the whole FAT1 table to 0x8000
    ; load sector 1 to 9 to 0x8000
    mov bx, 0x0800
;    push bx ; save this address for later increment
;    mov es, bx ; 0x800 << 16 + 0x00 = 0x8000
;    mov bx, 0x00
;
    mov dx, 9 ; variable to control loop
    mov ax, 1 ; start number of FAT1 table sector
;    mov cl, 1

LoadNextFAT1Sector:
    push bx ; save this address for later increment
    mov es, bx ; 0x800 << 16 + 0x00 = 0x8000
    mov bx, 0x00

;    mov dx, 9 ; variable to control loop
;    mov ax, 1 ; start number of FAT1 table sector
    mov cl, 1
    push ax
    push dx
    call Func_ReadOneSector
    pop dx
    pop ax
    inc ax

    pop bx
    add bx, 0x0020 ; move base address forward 512 bytes

    dec dx
    jnz LoadNextFAT1Sector

    ; restore the register value
    pop ax
NextFATEntry:
    ; load sector indicated by ax
    ; judge if hit the end, 0xFF8 ~ 0xFFF
    cmp ax, 0xff8
    jl file_not_end

    cmp ax, 0xfff
    jg file_not_end

    ; file end
    ret

file_not_end:
    ; physical sector no = (FAT - 2) * BPB_SEcPerClus + First physector no
    push ax ; save FAT value
    add ax, 31
    call Func_LoadSectorByFAT
    pop ax ; restore to FAT value
    ; FAT entry are 12 bits each, two occupy two bytes
    test al, 1
    jz FAT_Even
    jmp FAT_Odd

FAT_Even:
    ; (n/2)*3
    ; divided by 2
    shr ax, 1
    mov bx, ax
    ; multiplied by 3
    shl ax, 1
    add ax, bx
    ; add bytes to the base address
    add ax, 0x8000
    ; calculate 12 bits FAT value
    ; lower 8 bits
    mov dx, 0x0000 ; base address
    mov ds, dx
    mov si, ax ; put address to si register
    mov ax, [si] ; read two bytes
    and ax, 0x0fff

    jmp NextFATEntry

FAT_Odd:
    ; (n/2)*3+1
    ; divided by 2
    shr ax, 1
    mov bx, ax
    ; multiplied by 3
    shl ax, 1
    add ax, bx
    inc ax
    ; add bytes to the base address
    add ax, 0x8000
    ; calculate 12 bits FAT value
    ; lower 8 bits
    mov dx, 0x0000 ; base address
    mov ds, dx
    mov si, ax ; put address to si register
    mov ax, [si] ; read two bytes

    shr ax, 4

    jmp NextFATEntry

Load_SectorbyFAT:

    ret

;==== function to load sector to 0x10000
; ax indicate the actual sector to load
Func_LoadSectorByFAT:
    mov bx, OffsetOfLoader ; 0x10000 offset
    mov cx, [loader_start_base] ; 0x10000 base address,
    mov es, cx ; 0x7e0 << 16 + 0x00 = 0x7e00
    add cx, 0x20
    mov [loader_start_base], cx
    mov cl, 1 ; read one sector at a time
    call Func_ReadOneSector
    ret

; subfunction: print value in hex format
; input: DX register
; output: no paramaters returned, direcly render on screen
;print_hex:
;    mov cx, 4
;    lea di, [hex_msg+5] ; set the address to "0x..."
;
;convert_loop:
;        mov ax, dx
;        and al, 0x0F ; calculate the lower 4 digits
;
;        cmp al, 9
;        jle print_hex_convert_digit
;        add al, 'A' - '9' - 1 ; calculate the distance
;
;print_hex_convert_digit:
;    add al, '0'
;    mov [di], al
;    dec di
;
;    ; shift right 4 digits
;    shr dx, 4
;
;    loop convert_loop
;    mov bx, hex_msg
;    call print_string
;    ret


;==== string address in the bx register
; loop the string until hit '0' and then stop and return
print_string:
    ; save register status
    push bx
    ; first set the focus position
    mov ah, 0x02
    mov bh, 0
    mov dh, [focus_line_num]
    mov dl, 0
    int 0x10
    inc byte [focus_line_num] ; set focus to the next line
    ; restore register status
    pop bx
print_string_start:
    mov al, [bx]
    cmp al, 0
    je print_string_end
    push ax
    push bx
    call print_char
    pop bx
    pop ax
    inc bx
    jmp print_string_start
print_string_end:
    ret

print_char:
    mov ah, 0x0e
    int 0x10
    ret

StartBootMessage db 'boot start!', 0
loader_name db 'LOADER  BIN' ; fixed length of 11 bytes
;found_loader_msg db 'Found LOADER.BIN!', 0 ; msg for found loader bin
not_found_loader_msg db 'No LOADER.BIN!', 0 ; msg for found loader bin
;hex_msg db '0x0000', 0 ; msg used to store the hex number
focus_line_num db 0
loader_start_base dw BaseOfLoader

;loader_FLC db 'First Logical Cluster:', 0
;loader_FS db 'File Size(in bytes):', 0

; ==== fill zero until whole sector
    times 510 - ($ - $$) db 0
    dw 0xaa55

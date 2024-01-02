;===== org means Origin, if not specified, the program will take 0x0000 as start address
org 0x7c00

;===== this BaseOfStack provides intial value for the SP register
BaseOfStack             equ 0x7c00
BaseOfLoader            equ 0x1000
OffsetOfLoader          equ 0x00
BaseOfTmpRootDir        equ 0x07e0
OffsetOfTmpRootDir      equ 0x00
AddressOfTmpRootDir     equ 0x7e00
BaseOfFAT1              equ 0x0800
OffsetOfFAT1            equ 0x00

RootDirSectors          equ 14
SectorNumOfRootDirStart equ 19
SectorNumOfFAT1Start    equ 1
SectorBalance           equ 17
DirNuminOneSctor        equ 16
RootDirEntryBytes       equ 32
RootDirNameAttrBytes    equ 11

;===== Boot Sector of Fat12 Floppy
jmp short Label_Start
nop ; fill the first 3 bytes, no operation
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
;==== Boot Sector Occupy 62 bytes, the rest will be boot code

;=============================Main Boot start!============================================
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
    call Func_PrintString

;==== search and load LOADER.BIN file
;==== loop from sector 19 to 32, load every sector to BaseOfTmpRootDir
    mov bx, OffsetOfTmpRootDir
    mov ax, BaseOfTmpRootDir
    mov es, ax ; BaseOfTmpRootDir << 16 + OffsetOfTmpRootDir

    mov dx, RootDirSectors ; variable for loop control
    mov ax, SectorNumOfRootDirStart ; start sector num
    mov cl, 1 ; read one sector at a time

Label_LoadNextSector:
    ; save registers status before sub function
    push cx
    push ax
    push dx
    push bx
    call Func_ReadOneSector
    call Func_TraverseDirEntries
    jc CurrSectorFoundLoaderBin
    ; restore registers status after sub function
    pop bx
    mov ax, BaseOfTmpRootDir
    mov es, ax ; BaseOfTmpRootDir << 16 + OffsetOfTmpRootDir
    pop dx
    pop ax
    pop cx

    ; operate the control variables
    inc ax
    dec dx
    jnz Label_LoadNextSector

    ; no loader in floppy
    mov bx, NoLoaderMessage
    call Func_PrintString

    ; boot program stuck here
    jmp $

;==== jump to LOADER.BIN and execute
CurrSectorFoundLoaderBin:
    add sp, 8 ; restore the stack pointer
    ; registers are prepared by Func_TraverseDirEntries
    call Func_LoadLoader
    jmp BaseOfLoader:OffsetOfLoader

;=============================Main Boot Done!============================================

; ------------------------------------------------
; Function Name: Func_ReadOneSector
; Description: Read one sector data to RAM
; Input Parameters:
;   - Param 1:AX - start sector number to be read
;   - Param 2:CL - number of sectors to be read
;   - Param 3:ES:BX - target address in RAM, (ADDRESS = ES << 16 + BX)
; Output:
;   - No return value, ret means read success, or keep trying
; Notes:
; This program will transform LBA format to CHS format for int 13h usage
; ------------------------------------------------
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

Label_GoOnReading:
    mov ah, 2
    mov al, byte [bp - 2]
    int 13h
    jc Label_GoOnReading
    add sp, 2
    pop bp
    ret

; ------------------------------------------------
; Function Name: Func_TraverseDirEntries
; Description: Traverse the Dir sector loaded to RAM looking for LOADER.BIN
; Input Parameters:
;   - No Param
; Output:
;   - Return Value 1: Carry Flags Indicate Whether Found LOADER.BIN
;   - Return Value 2: AX - LOADER.BIN First Logical Cluster
;   - Return Value 3: BX - LOADER.BIN size lower size (2 bytes)
;   - Return Value 4: CX - LOADER.BIN size higher size (2 bytes)
; Notes:
; When success this program will use register to pass return value, do not override!
; ------------------------------------------------
Func_TraverseDirEntries:
    mov ax, AddressOfTmpRootDir
    mov dx, DirNuminOneSctor
Label_LoadNextDir:
    push ax
    push dx
    mov bx, ax
    call Func_CmpLoaderName
    jc Label_FoundLoaderBinInDir
    pop dx
    pop ax

    add ax, RootDirEntryBytes ; jump 32 bytes at a time
    dec dx
    jnz Label_LoadNextDir

    ; not found loader.bin!
    clc ; clear carry flag to indicate failure
    ret

Label_FoundLoaderBinInDir:
    pop dx
    pop ax
    add ax, 26
    mov dx, 0x0000 ; base address
    mov ds, dx
    mov si, ax ; put address to si register
    mov ax, [si] ; First Logical Cluster

    add si, 2
    mov bx, [si] ; file size lower 2 bytes
    add si, 2
    mov cx, [si] ; file size higher 2 bytes

    ; found loader.bin!
    stc ; set carry flag to indicate success
    ret

; use the address of bx register
; ------------------------------------------------
; Function Name: Func_CmpLoaderName
; Description: compare the name in address bx with "LOADER   .BIN"
; Input Parameters:
;   - Input Param 1: BX - Start Address of File Name
; Output:
;   - Return Value 1: Carry Flags Indicate Whether name Identical
; ------------------------------------------------
Func_CmpLoaderName:
    mov dx, RootDirNameAttrBytes
    mov si, LoaderNameStr

Label_CmpNextChar:
    lodsb ; load 1 byte from si address to al
    cmp al, [bx]
    jne Label_NotLoaderName

    ; move to the next pos
    inc bx
    dec dx
    jnz Label_CmpNextChar

    ; Name is loader.bin!
    stc ; set carry flag to indicate success
    ret

Label_NotLoaderName:
    ; Name is not loader.bin!
    clc ; clear carry flag to indicate failure
    ret

; ------------------------------------------------
; Function Name: Func_LoadLoader
; Description: load loader program to RAM
; Input Parameters:
;   - Param 1:AX - First Logical Cluster
;   - Param 2:BX - File Size lower 2 bytes
;   - Param 2:CX - File Size higher 2 bytes
; Output:
;   - No Return Value
; Notes:
; This program will load the entire Loader program to 0x1000
; ------------------------------------------------
Func_LoadLoader:
    ; save the register value
    push ax

    ; load the whole FAT1 table
    mov bx, BaseOfFAT1
    mov dx, 9 ; variable to control loop
    mov ax, 1 ; start number of FAT1 table sector

Label_LoadNextFAT1Sector:
    push bx ; save this address for later increment
    mov es, bx ; BaseOfFAT1 << 16 + OffsetOfFAT1
    mov bx, OffsetOfFAT1

    mov cl, 1 ; read one secor at a time
    push ax
    push dx
    call Func_ReadOneSector
    pop dx
    pop ax
    inc ax
    pop bx
    add bx, 0x0020 ; move base address forward 512 bytes

    ; control variables
    dec dx
    jnz Label_LoadNextFAT1Sector

    ; restore the register value
    pop ax
Label_NextFATEntry:
    ; judge if hit the end, 0xFF8 ~ 0xFFF
    cmp ax, 0xff8
    jl Label_FileNotEnd

    cmp ax, 0xfff
    jg Label_FileNotEnd

    ; file reach end
    ret

Label_FileNotEnd:
    ; physical sector no = (FAT - 2) * BPB_SEcPerClus + First physector no
    push ax ; save FAT value
    add ax, 31
    call Func_LoadSectorByFAT
    pop ax ; restore to FAT value
    ; FAT entry are 12 bits each, two occupy two bytes
    test al, 1
    jz Label_FAT_Even
    jmp Label_FAT_Odd

Label_FAT_Even:
    ; (n/2)*3
    ; divided by 2
    shr ax, 1
    mov bx, ax
    ; x3 = multiplied by 2 and add it self
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

    jmp Label_NextFATEntry

Label_FAT_Odd:
    ; (n/2)*3+1
    ; divided by 2
    shr ax, 1
    mov bx, ax
    ; x3 = multiplied by 2 and add it self
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

    jmp Label_NextFATEntry

; ------------------------------------------------
; Function Name: Func_LoadSectorByFAT
; Description: Load the sector indicated by FAT number to RAM
; Input Parameters:
;   - Param 1:AX - actual sector to load
; Output:
;   - No return value, ret means read success, or keep trying
; Notes:
; This program will keep and change the loader base address in ram
; ------------------------------------------------
Func_LoadSectorByFAT:
    mov bx, OffsetOfLoader
    mov cx, [LoaderBase]
    mov es, cx ; LoaderBase << 16 + OffsetOfLoader
    add cx, 0x20 ; increment on base address, equals to 512 base on actual address
    mov [LoaderBase], cx
    mov cl, 1 ; read one sector at a time
    call Func_ReadOneSector
    ret

; ------------------------------------------------
; Function Name: Func_PrintString
; Description: Loop the string until hit '0'
; Input Parameters:
;   - Param 1:BX - starting address of string
; Output:
;   - No return value
; Notes:
; This program will keep a line number and print string on the next line
; ------------------------------------------------
Func_PrintString:
    ; save register status
    push bx
    ; set the focus position
    mov ah, 0x02
    mov bh, 0
    mov dh, [FocusLineNum]
    mov dl, 0
    int 0x10
    inc dh
    mov [FocusLineNum], byte dh
    ; restore register status
    pop bx
Label_PrintNextChar:
    mov al, [bx]
    cmp al, 0 ; judge if hit '0'
    je Label_PrintEnd
    push ax
    push bx
    call print_char
    pop bx
    pop ax
    inc bx
    jmp Label_PrintNextChar
Label_PrintEnd:
    ret

print_char:
    mov ah, 0x0e
    int 0x10
    ret

StartBootMessage db 'boot start!', 0
LoaderNameStr db 'LOADER  BIN' ; fixed length of 11 bytes
NoLoaderMessage db 'No LOADER.BIN!', 0 ; msg for found loader bin
LoaderBase dw BaseOfLoader
FocusLineNum db 0

; ==== fill zero until whole sector
    times 510 - ($ - $$) db 0
    dw 0xaa55

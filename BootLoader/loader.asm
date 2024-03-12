;===== org means Origin, if not specified, the program will take 0x0000 as start address
org 0xA000
jmp Label_Loader_Start

; kernel start point is 0x11000
BaseOfKernelFile            equ 0x0B00
OffsetOfKernelFile          equ 0x0000

;==== FAT 12 info
BPB_SecPerTrk               equ 18
BS_DrvNum                   equ 0

BaseOfTmpRootDir            equ 0x07E0
OffsetOfTmpRootDir          equ 0x00
AddressOfTmpRootDir         equ 0x7E00
BaseOfFAT1                  equ 0x0800
OffsetOfFAT1                equ 0x00

RootDirSectors              equ 14
SectorNumOfRootDirStart     equ 19
DirNuminOneSctor            equ 16
RootDirEntryBytes           equ 32
RootDirNameAttrBytes        equ 11

VGA_TEXT_MODE equ 0x3

;=============================Main loader start!============================================
[SECTION .s16]
[BITS 16]
;===== Program start point
Label_Loader_Start:
    mov ax, cs
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov ds, ax
    mov sp, 0x7c00

;==== clear screen
    mov ax, 0x0600
    mov bx, 0x0700
    mov cx, 0
    mov dx, 0x0184f
    int 0x10

;==== reset floppy
    xor ah, ah
    xor dl, dl
    int 0x13

;==== display on screen message
    mov bx, StartLoaderMessage
    call Func_PrintString

;==== search for kernel.bin
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
    jc CurrSectorFoundKernelBin
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

    ; no kernel in floppy
    mov bx, NoKernelMessage
    call Func_PrintString

    ; boot program stuck here
    jmp $

;==== load kernel.bin to BaseOfKernelFile:OffsetOfKernelFile
CurrSectorFoundKernelBin:
    add sp, 8 ; restore the stack pointer
    ; registers are prepared by Func_TraverseDirEntries
    call Func_LoadKernel
    ; jump to kernel and execute (same segment for test)
    ; jmp BaseOfKernelFile:OffsetOfKernelFile

    ; set VGA to text mode, 25*80
    mov ax, VGA_TEXT_MODE
    int 0x10

    ; Switch to Protected Mode
    jmp Func_SwitchTo32

    jmp $
;=============================Main loader end!============================================

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
    mov bl, BPB_SecPerTrk
    div bl
    inc ah
    mov cl, ah ; sector number(bit 0 - 5), cylinder number higher 2 bits (bit 6 - 7)
    mov dh, al
    shr al, 1 ; divided by 2 (Heads Per Cylinder)
    mov ch, al ; cylinder number lower 8 bits
    and dh, 1 ; head number (% operation to get the residual after divided by 2)
    pop bx
    mov dl, BS_DrvNum

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
; Description: Traverse the Dir sector loaded to RAM looking for KERNEL.BIN
; Input Parameters:
;   - No Param
; Output:
;   - Return Value 1: Carry Flags Indicate Whether Found KERNEL.BIN
;   - Return Value 2: AX - KERNEL.BIN First Logical Cluster
;   - Return Value 3: BX - KERNEL.BIN size lower size (2 bytes)
;   - Return Value 4: CX - KERNEL.BIN size higher size (2 bytes)
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
    call Func_CmpKernelName
    jc Label_FoundKernelBinInDir
    pop dx
    pop ax

    add ax, RootDirEntryBytes ; jump 32 bytes at a time
    dec dx
    jnz Label_LoadNextDir

    ; not found kernel.bin!
    clc ; clear carry flag to indicate failure
    ret

Label_FoundKernelBinInDir:
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

    ; found kernel.bin!
    stc ; set carry flag to indicate success
    ret

; ------------------------------------------------
; Function Name: Func_CmpKernelName
; Description: compare the name in address bx with "KERNEL   .BIN"
; Input Parameters:
;   - Input Param 1: BX - Start Address of File Name
; Output:
;   - Return Value 1: Carry Flags Indicate Whether name Identical
; ------------------------------------------------
Func_CmpKernelName:
    mov dx, RootDirNameAttrBytes
    mov si, KernelNameStr

Label_CmpNextChar:
    lodsb ; load 1 byte from si address to al
    cmp al, [bx]
    jne Label_NotKernelName

    ; move to the next pos
    inc bx
    dec dx
    jnz Label_CmpNextChar

    ; Name is kernel.bin!
    stc ; set carry flag to indicate success
    ret

Label_NotKernelName:
    ; Name is not kernel.bin!
    clc ; clear carry flag to indicate failure
    ret

; ------------------------------------------------
; Function Name: Func_LoadKernel
; Description: load kernel program to RAM
; Input Parameters:
;   - Param 1:AX - First Logical Cluster
;   - Param 2:BX - File Size lower 2 bytes
;   - Param 2:CX - File Size higher 2 bytes
; Output:
;   - No Return Value
; Notes:
; This program will load the entire kernel program to 0x1000
; This program willl lod the kernel one sector after another to
; BaseTmpOfKernelAddr:OffsetTmpOfKernelFile address, then move to
; BaseOfKernelFile:OffsetOfKernelFile which starting from 1MB
; ------------------------------------------------
Func_LoadKernel:
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
; This program will keep and change the kernel base address in ram
; ------------------------------------------------
Func_LoadSectorByFAT:
    mov bx, OffsetOfKernelFile
    mov cx, [KernelBase]
    mov es, cx ; KernelBase << 16 + OffsetOfLoader
    add cx, 0x20 ; increment on base address, equals to 512 base on actual address
    mov [KernelBase], cx
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
    call Func_PrintChar
    pop bx
    pop ax
    inc bx
    jmp Label_PrintNextChar
Label_PrintEnd:
    ret

; ------------------------------------------------
; Function Name: Func_PrintChar
; Description: Print one Char on the screen
; Input Parameters:
;   - Param 1:AL - address of the char
; Output:
;   - No return value
; ------------------------------------------------
Func_PrintChar:
    mov ah, 0x0e
    int 0x10
    ret

StartLoaderMessage db "loader program start!", 0
FocusLineNum db 0
KernelNameStr db 'KERNEL  BIN' ; fixed length of 11 bytes
NoKernelMessage db 'No KERNEL.BIN!', 0 ; msg for found loader bin
KernelBase dw BaseOfKernelFile

; ------------------------------------------------
; GDT defination Flat Model Start
; ------------------------------------------------
GDT_Start:
GDT_Null: ; 8 bytes null GDT entry
    dd 0x0 ; the mandatory null descriptor for debug
    dd 0x0

GDT_Code: ; the code segment descriptor
    ; base address = 0x0, limit = 0xffff (which will be controled by Granularity)
    ; 1st flags: (P)1 (DPL)00 (TYPE)1 -> 1001b
    ; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b
    ; 2nd flags: (graularity)1 (32-bit default)1 (64-bit seg) 0 (AVL) 0 -> 1100b
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10011010b    ; 1st flags, type flags
    db 11001111b    ; 2nd flags, Limit (bits 16-19)
    db 0x0          ; Base (bits 24-31)

GDT_Data: ; the data segment descriptor
    ; same as the code segment except for the type flags
    ; type flags: (code) 0 (expands down)0 (wrtable)1 (accessed)0 -> 0010b
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10010010b    ; 1st flags, type flags
    db 11001111b    ; 2nd flags, Limit (bits 16-19)
    db 0x0          ; Base (bits 24-31)

GDT_End:

; GDT descriptor
GDT_Descriptor:
    dw GDT_End - GDT_Start - 1  ; size of GDT
    dd GDT_Start                ; start address of GDT

; jump address for far jump
CODE_SEG equ GDT_Code - GDT_Start
DATA_SEG equ GDT_Data - GDT_Start
; ------------------------------------------------
; GDT defination Flat Model End
; ------------------------------------------------

Func_SwitchTo32:
    ; open address A20
    in al, 0x92
    or al, 0b00000010
    out 0x92, al

    cli ; first forbidden the interrupt
    lgdt [GDT_Descriptor]

    ; set PE bit of CR0
    mov eax, cr0    ; When in 16-bit real mode, we can still use eax to operate 32-bit register
    or al, 0x1
    mov cr0, eax ; set PE (Protection Enable) bit in CR0 (Control Register 0)

    ; perform a far jump to force the CPU clear pipeline
    jmp dword CODE_SEG:Func_PMStart

;=============================Swithc to 32-bit mode start!==========================================
[SECTION .s32]
[BITS 32]
; constants used by the function
VIDEO_MEMORY equ 0xB8000
WHITE_ON_BLACK equ 0x0f

; ------------------------------------------------
; Function Name: Func_PMStart
; Description: Prepare the stacks and print messages
; Output:
;   - No return value
; ------------------------------------------------
Func_PMStart:
Label_InitStack:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x7c00 ; update the stack position
    mov esp, ebp

Label_PrintWelMsg:
    mov ebx, PMMessage
    call Func_PrintString32
    jmp $ ; pending after print this message

; ------------------------------------------------
; Function Name: Func_PrintString32
; Description: Print a null terminated string on screen
; Input Parameters:
;   - Param 1:EBX - address of the string
; Output:
;   - No return value
; ------------------------------------------------
Func_PrintString32:
    mov edx, [PrintString32StartingAddress]

Label_PrintCharLoop:
    mov al, [ebx] ; char to print
    mov ah, WHITE_ON_BLACK ; attributes for this char

    cmp al, 0
    je Label_PrintString32Done ; if hit null, terminate

    mov [edx], ax
    add ebx, 1 ; Increment to read the next char in the string
    add edx, 2 ; move to the next memory cell of VGA memory

    jmp Label_PrintCharLoop

Label_PrintString32Done:
    mov edx, PrintString32StartingAddress
    add edx, 0xa0 ; move the next line start position
    mov [PrintString32StartingAddress], dword edx ; save the value back to memory
    ret


PrintString32StartingAddress dd VIDEO_MEMORY
PMMessage db "Entering 32-bit protected mode!", 0
;=============================Swithc to 32-bit mode end!============================================

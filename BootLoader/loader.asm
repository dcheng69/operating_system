;===== org means Origin, if not specified, the program will take 0x0000 as start address
org 0x10000

;=============================Main loader start!============================================
;===== Program start point
Label_Loader_Start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00

;==== clear screen
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 0184fh
    int 10h

;==== display on screen message
    mov bx, StartLoaderMessage
    call Func_PrintString

    jmp $
;=============================Main loader end!============================================


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

StartLoaderMessage db "loader program start!"
FocusLineNum db 0

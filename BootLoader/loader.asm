;===== org means Origin, if not specified, the program will take 0x0000 as start address
org 0x10000

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
    call print_string

    jmp $


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


focus_line_num db 0
StartLoaderMessage db "loader program start!"

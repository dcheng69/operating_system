# Loader Program

This markdown file is to record the developing process of the loader program, and explain some of the details that I have learned through the process of my learning.

## Objectives

The operating system starts from the boot program, which has a limitation of 512 bytes, you can not do much with it, so the primary goal of boot program is to load the loader program to the RAM and jump to the right address to run the loader program. Therefore, the responsibility of loader program is to switch from 16-bit real mode, to 32-bit mode and further 64-bit mode. The reason behind this is obvious, more bits means more memory can be addressed, as well as IO device, which will also be mapped into memory, especially in Embedded Systems.

In order to switch to the 32-bit mode, we will divided this process into different stages:

1. Modify the loader program to load a temp `kernel.bin` (written in assembly)  **16-bit Real Mode**
2. Modify the loader program to switch to 32-bit protected mode and then write a simple 32-bit `kernel.bin` (written in assembly)
3. Rewrite the kernel program with `C` language

We will spend some time on `32-bit` protected mode to develop a basic kernel before we move to the `64-bit` mode.

## Kernel In 16-bit Real Mode

### Memory Arrangement

Before we start working on the first mile-stone mentioned above, we need to redesign the memory spaces with some detailed explanation:

![Memory Layout](../Documentation/res/BootLoaderMemoryArrangement.draw.io.drawio.png)

Because the stacks for the functions grows downwards, so we put the base pointer to the `0x7c00` to use the Free space from `0x0500` to `0x7C00`

Then we Leave some spaces for FAT root directory and the `FAT1` table, for searching and loading purpose.

Finally we leave `4KB` for the loader program, and leave the rest to the kernel program.

**Note:**

The reason why we only use the memory of below `0x100000` is that the segment model, the register for real mode is 16-bit wide each, however the CPU has 20 wire lines for address. So software engineers think of a way to use two 16-bit registers to represent a 20-bit address called memory segmentation:

```bash
BaseAddress << 16 + OffsetAddress

; For example 0x7C00 be expressed
0x07C0:0x0000
9x0000:0x7C00
....


The upper limit for 20 address lines are `0x1000000`, We will learn how to address up to `4GB` memory in the future.

### Code Explanation

1. Up on jump to the loader to execute, there is a piece of code that set up the segment registers

```asm
Label_Loader_Start:
    mov ax, cs            ; get the current value of code segment
    mov es, ax            ; assign to es register
    mov ax, 0x00          ; assign 0 to ax
    mov ss, ax            ; assign 0 to stack segment
    mov ds, ax            ; assign 0 to data segment
    mov sp, 0x7c00        ; set stack pointer
    
; segment registers can be displayed when you type sreg in bochs
<bochs:3> sreg
es:0x0a00, dh=0x00009300, dl=0xa000ffff, valid=1
	Data segment, base=0x0000a000, limit=0x0000ffff, Read/Write, Accessed
cs:0x0a00, dh=0x00009300, dl=0xa000ffff, valid=1
	Data segment, base=0x0000a000, limit=0x0000ffff, Read/Write, Accessed
ss:0x0000, dh=0x00009300, dl=0x0000ffff, valid=7
	Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
ds:0x0000, dh=0x00009300, dl=0x0000ffff, valid=3
	Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
fs:0x0000, dh=0x00009300, dl=0x0000ffff, valid=1
	Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
gs:0x0000, dh=0x00009300, dl=0x0000ffff, valid=1
	Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
ldtr:0x0000, dh=0x00008200, dl=0x0000ffff, valid=1
tr:0x0000, dh=0x00008b00, dl=0x0000ffff, valid=1
gdtr:base=0x00000000000f9af7, limit=0x30
idtr:base=0x0000000000000000, limit=0x3ff
<bochs:4> 

; we should know that in real mode, the address is located with base << 16 + offset
; and the base address are stored in these segment registers
; in protected mode and beyond they will point to a more secure data structure called
; segment descriptor
```

2. We should notice that, the function `Func_CmpKernelName` use `si` to store the address, which means this function will locate variable with following format, so if you get the wrong value, remember to check this register!

```asm
; ds stands for data segment
ds << 16 + si
```



As for the rest of the code it's basically the same with the boot sector to load loader to the RAM, but someone may say that why do I load `FAT1` sectors twice (boot once, and loader once). The reason is that I considered that there maybe future modification of the memory arrangement for the loader program, so I keep this piece of code so that whenever I want, I can change the macro directly!

# Reference

1. https://wiki.osdev.org/Memory_management

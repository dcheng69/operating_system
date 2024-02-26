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
```

The upper limit for 20 address lines are `0x1000000`, We will learn how to address up to `4GB` memory in the future.

# Reference

1. https://wiki.osdev.org/Memory_management

# Operating Learning
This repo is a test repo for developing operating system
## Introductino to the OS
### BIOS
Upon the computer power on, the chip provides Basic Input/Output Software(BIOS), a collection of software routines that are initially loaded from a chip into memory and initialized. \
BIOS provides auto-detection and basic control of your computer's essential devices, such as the screen, keyboard, and hard disks. \
After BIOS completes some low-level tests of the hardware, it will boot the operating system stored on one of your devices. However, BIOS has no file-system, thus by convention, it will read specific sectors of data (usually **512 bytes** in size) from specific physical locations of the disk devices, such as Cylinder 0, Head 0, Sector 0, whichi is known as **boot sector**.

However, our disks contain not only operating system, they may simply be storages data, Thus by convention that, the last two bytes of an intended boot sector must be set to the magic number **0xaa55**.

So BIOS loops through each possible storage device (floppy hard disk, CD drive etc.), reads the boot sector into memory and instructs the CPU to begin executing the first boot sector.

### Boot
512 bytes is too small to hold the entire operating system, thus the boot program is responsible for load the Loader program to the RAM. It is the Loader program who is responsible for loading the Entire Operating system into RAM.

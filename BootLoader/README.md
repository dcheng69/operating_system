# Boot Program on Floppy Disk
We will first start with a 1.44MB Floppy disk. Although Floppy Disk is rarely used today, yet it is simple enough to let us focus on developing the Boot program at the begining.

[x86 Assembly Guide](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html)

## Create a Floppy Disk on ubuntu
Using the tools provided with bochs to create an floppy image disk \
1. run `bximage` command and follow the instructions listed below to create an floppy disk named boot.img
```bash
========================================================================
                                bximage
  Disk Image Creation / Conversion / Resize and Commit Tool for Bochs
         $Id: bximage.cc 14091 2021-01-30 17:37:42Z sshwarts $
========================================================================

1. Create new floppy or hard disk image
2. Convert hard disk image to other format (mode)
3. Resize hard disk image
4. Commit 'undoable' redolog to base image
5. Disk image info

0. Quit

Please choose one [0] 1

Create image

Do you want to create a floppy disk image or a hard disk image?
Please type hd or fd. [hd] fd

Choose the size of floppy disk image to create.
Please type 160k, 180k, 320k, 360k, 720k, 1.2M, 1.44M, 1.68M, 1.72M, or 2.88M.
 [1.44M] 1.44M

What should be the name of the image?
[a.img] boot.img

Creating floppy image 'boot.img' with 2880 sectors

The following line should appear in your bochsrc:
  floppya: image="boot.img", status=inserted

```
2. create a simple assembly code file then compile it into binary code, finally burns the binary code into the boot.img we just created, (code in boot.asm)
```bash
# compile the assembly code
nasm boot.asm -o boot.bin
# examine the size of the boot.in, shold be 512 bytes
ls -lh
# copy the binary code to the proper position of the floppy
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
# results:
1+0 records in
1+0 records out
512 bytes copied, 0.00023439 s, 2.2 MB/s

# setup the bochsrc : https://bochs.sourceforge.io/doc/docbook/user/bochsrc.html
# finally, boot up the system with the boot.img
bochs -f ./bochsrc

# seeing below instructions, hit c to continue!
Next at t=0
(0) [0x0000fffffff0] f000:fff0 (unk. ctxt): jmpf 0xf000:e05b          ; ea5be000f0
```

## Format the Floppy to FAT12 file system format

The aim of boot program is to find and load loader program to the RAM and start running loader program.

The loader program can change overtime, which means its size can change. If  we format the Floppy with a file system then we can always load a loader file without changing the boot sector code.

For FAT file system, it is easy to format with assembly code and easy to find terminal tool to copy loader.bin file into it, but to validate our program written in assembly code, we will need to dive further into the FAT file system.



### FAT12 Format Brief

Write c/cpp code to traverse the file system on floppy and list the file name and file size and other informations.

```bash
The Volume of the 1.44MB Floppy Disk
1.44MB = 1.44 * 1000 KB = 1440KB = 1440 * 1024 = 1474567B
```

**Note:**

Originally the manufacturer of the Floppy disk calculate the volume in KB by using the `tracks, sectors, sides`. Then when they get the KB they simply divided it with 1000 to get MB for a number that is easier to memorize.

```bash
Each sector occupies 512 Bytes, thus a 1.44MB Floppy has the following secotrs
1474567 Bytes / 512 Bytes = 2880 sectors

Since the sector number starts from 0, then it is 0 ~ 2079
```

When we get the 0 ~ 2079 sectors, we can divide them according to the definition of the FAT 12 file system

```bash
0 :Boot Sector
1 - 9: FAT Table (FAT1)
10 - 18: FAT Table (FAT2)
19 - 32: Root Directory
33 - 2879: Data Area
```

The definition above comes from the disk information we defined in the Boot Sector, for a 1.44MB Floppy disk, the above definition is the most appropriate one.

**The Boot Sector**

| name                     | offset | length | description                                          | actual value              |
| ------------------------ | ------ | ------ | ---------------------------------------------------- | ------------------------- |
| BS_jmpBoot               | 0      | 3      | jmp instruction                                      | jmp short Label_Start nop |
| BS_OEMName               | 3      | 8      | Vendor Name                                          | TestBoot                  |
| BPB_BytesPerSec          | 11     | 2      | bytes per sector                                     | 512                       |
| BPB_SecPerClus           | 13     | 1      | sectors per cluster                                  | 1                         |
| BPB_RsvdSecCnt           | 14     | 2      | number of reserved sectors                           | 1                         |
| BPB_NumFATs              | 16     | 1      | Number of FATs                                       | 2                         |
| BPB_RootEntCnt           | 17     | 2      | Maximum number of root directory entries             | 224                       |
| BPB_TotSec16             | 19     | 2      | total sector count                                   | 2880                      |
| BPB_Media                | 21     | 1      | Descriptor of the disk                               | 0xF0                      |
| BPB_FATSz16              | 22     | 2      | sectors per FAT                                      | 9                         |
| BPB_SecPerTrk            | 24     | 2      | sectors per track                                    | 18                        |
| BPB_NumHeads             | 26     | 2      | number of heads                                      | 2                         |
| BPB_HiddSec              | 28     | 4      | number of hidden sectors                             | 0                         |
| BPB_TotSec32             | 32     | 4      | total sector count for FAT32 (0 for FAT12 and FAT16) | 0                         |
| BS_DrvNum                | 36     | 1      | drive number of int 13h                              | 0                         |
| BS_Reserved1             | 37     | 1      | Unused                                               | 0                         |
| BS_BootSig               | 38     | 1      | boot signature (29h)                                 | 0x29                      |
| BS_VolID                 | 39     | 4      | volume id                                            | 0                         |
| BS_VolLab                | 43     | 11     | volume label                                         | 'boot loader'             |
| BS_FileSysType           | 54     | 8      | File system type                                     | 'FAT12   '                |
| other code               | 62     | 448    | boot code, data and other information                |                           |
| boot sector notification | 510    | 2      | 0xAA55                                               | 0xAA55                    |

### Code to Traverse the file of the Floppy

1. First write cpp code to read and print all the information of the boot sector 0 - 62

```
(base) ➜  BootLoader git:(boot) ✗ ./a.out
BS_OEMName: TestBoot
BPB_BytesPerSec: 512
BPB_SecPerClus: 1
BPB_RsvdSecCnt : 1
BPB_NumFATs : 2
BPB_RootEntCnt : 224
BPB_TotSec16 : 2880
BPB_Media : 0x00f0
BPB_FATSz16 : 9
BPB_SecPerTrk: 18
BPB_NumHeads : 2
BPB_HiddSec: 0
BPB_TotSec32: 0
BS_DrvNum: 0
BPB_BootSig : 0x0029
BS_VolID: 0
BS_VolLab : boot loader
BS_FileSysType : FAT12   

Bytes read so far: 62
```

## Assembly Code to Locate and Load Loader.bin file

Since we already have a FAT12 file system, we will need to write Assembly code to locate the loader program we want the boot program to locate and load.

### Code to Load a Sector to Memmory

By using interrupt `13h ah=02h` we will be able to read a designated number of sectors into the address we want it to be loaded.

However, This BIOS interrupt accept CHS (Cylinder/Head/Sector) format of address, in order to make our use easier, we need to write a function that accept LBA(Logical Block Address).

To do that, we need first figure out the conversion between these two format of addresses

**LBA and CHS**

```bash
LBA = (C-CS)*HPC*SPT + (H-HS)*SPT + (S-SS)

where:
C, H, S represent Cylinder, Head, Sector
CS, HS, SS represent the start number of Cylinder, Head and Sector, for floppy, CS=0, HS=0, SS=1
HPS represents heads per cylinder (you can also imagine cylinder as a ring for floppy because it only has one plate and has two sides), for floppy HPC=2
SPT represents sectors per track, for 1.44MB floppy, SPT=18
```

**How to Get C H S from LBA Address**

```
Because CS = 0, HS = 0, SS = 1
then:
LBA = C*HPC*SPT + H*SPT + (S-1)
LBA = (C*HPC+H)*SPT + (S-1)

HPC = 2 and SPT= 18 for 1.44MB floppy
then:
LBA = (2*C + H)*18 + (S - 1)

Because previous sector must be filled before move to the next sector
then:
S = LBA%SPT + 1 (Sector number start from 1)

Because previous head must be filled before move to the next head
then:
H = (LBA/SPT) % HPC

Because previous cylinder must be filled before move to the next Cylinder
C = LBA/ (SPT * HPC)
```

### Code to Traverse Root Dir

In order to find file with specific name, we need to write assembly code to traverse the Root Dir. Good thing is that we already know the start sector of the Root Dir, which is `19`

Then we have to load all the sectors (19 - 32) to an address that will not override the boot sector load to `0x7c00`, because the boot sector occupies `512 = 0x200` bytes, `0x7c00 + 0x200 = 0x7e00` thus, the `0x7e00` will be a good position to store the sector of root directory.

Since we are already there, we better draw a preliminary sketch of the lower memory layout after boot

![fat12_disk_distribution](../Documentation/res/fat12_disk_distribute.png)

![lower memory layout](../Documentation/res/lower_memory_layout_after_boot.png)

**Logic of Traverse the Root Dir:**

1. Using `dd if=boot.bin of=boot.img bs=512 count=1 seek=19 conv=notrunc` to copy the boot sector to the 20 sector (sector 19 when start from 0). And examine the value and the size of the `boot.img`

```
-rwxrwxrwx 1 root root 10K Dec 28 17:19 boot.img
```

2. Then use the below assembly code to load the sector 19 to `0x7e00`, as we can see

```
;==== search loader.bin file
;==== loop from sector 19 to 32, load every sector to the RAM
Func_FindLoaderBin:
    mov bx, 0x00 ; offset
    mov ax, 0x7e0 ; base address, 
    mov es, ax ; 0x7e0 << 16 + 0x00 = 0x7e00 is the destination address

    mov ax, SectorNumOfRootDirStart
    mov cl, 1 ; read one sector at a time

    call Func_ReadOneSector
    ret
```

3. execute the code and examine the value in RAM using bochs command,  we can check the last two bytes of the results, see if they are `0x55 0xaa`.

```
<bochs:3> help x
x  /nuf <addr> - examine memory at linear address
xp /nuf <addr> - examine memory at physical address
    nuf is a sequence of numbers (how much values to display)
    and one or more of the [mxduotcsibhwg] format specificators:
    x,d,u,o,t,c,s,i select the format of the output (they stand for
        hex, decimal, unsigned, octal, binary, char, asciiz, instr)
    b,h,w,g select the size of a data element (for byte, half-word,
        word and giant word)
    m selects an alternative output format (memory dump)
<bochs:4> x /512xb 0x7e00
...........
```

4. Write code to traverse all the sector in root directory sectors.

```
;==== search loader.bin file
;==== loop from sector 19 to 32, load every sector to the RAM
Func_FindLoaderBin:
    mov bx, 0x00 ; offset
    mov ax, 0x7e0 ; base address, 
    mov es, ax ; 0x7e0 << 16 + 0x00 = 0x7e00 is the destination address

    mov dx, RootDirSectors ; variable for loop control

LoadNextSector:
    mov ax, SectorNumOfRootDirStart
    mov cl, 1 ; read one sector at a time

    ; save registers status before sub function
    push cx
    push ax
    push dx
    push bx
    call Func_ReadOneSector
    ; restore registers status after sub function
    pop bx
    mov ax, 0x7e0 ; base address, 
    mov es, ax ; 0x7e0 << 16 + 0x00 = 0x7e00 is the destination address
    pop dx
    pop ax
    pop cx
    
    dec dx
    jnz LoadNextSector

    ret
```

5. Modify the code to Traverse all directory entry (32 bytes each) for every sector loaded.

```
; this function traverse the sector loaded to the 0x7e00
Func_ReadDirEntries:
    mov ax, 0x7e00 - 32
    mov dx, DirNuminOneSctor
LoadNextDir:
    add ax, 32 ; jump 32 bytes a time
    ; read and display the name of this sector

    dec dx
    jnz LoadNextDir

    ret
```

6. Modify the code to compare every directory name with `LOADER.BIN`, which to compare the first [0 .. 4] bytes one by one and then compare the [8 .. 10]

### Code to Load loader.bin to RAM

1. Print the `First Logical Cluster` and `File Size` of `LOADER.BIN`

```
; function to load loader.bin to the RAM
; paramaters:
;   ax: First Logical Cluster
;   bx: File Size high 2 bytes
;   cx: File Size lower 2 bytes
Func_LoadLoader:
    push cx
    push bx

    push ax
    mov bx, loader_FLC
    call print_string
    pop ax

    mov dx, ax
    call print_hex

    mov bx, loader_FS
    call print_string
    pop bx
    mov dx, bx
    call print_hex
    pop cx
    mov dx, cx
    call print_hex

    ret
```

2. According to the First Logical Cluster to locate its position in FAT table and load sectors one by one to `0x10000`

```
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
```

3. Now load sectors indicated by FAT table one sector after another, in the mean time we need to calculate the FAT number

```
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
```

![lower memory layout](../Documentation/res/FAT_expression_of_files.png)

# References

https://www.partitionwizard.com/partitionmanager/floppy-disk-size.html

https://en.wikipedia.org/wiki/Memory_segmentation

https://en.wikipedia.org/wiki/INT_13H

https://iitd-plos.github.io/os/2020/previous_years/2014/bochs/internal-debugger.html#:~:text=set%20reg%20%3D%20expr%20Change%20a%20CPU%20register,CPU%20registers%20and%20their%20contents%20regs%20reg%20r

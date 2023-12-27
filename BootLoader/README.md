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

1. First write code to read and print all the information of the boot sector 0 - 62

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

2. Then write code to Traverse the Directory to list all the file in the floppy



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



# References

https://www.partitionwizard.com/partitionmanager/floppy-disk-size.html

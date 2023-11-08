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

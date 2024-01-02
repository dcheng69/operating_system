# Bochs
Using bochs as a virtual environment for the operating system before migrating to the actual machine. \
https://github.com/bochs-emu/Bochs \
https://bochs.sourceforge.io/ \
[Install Guide](https://www.cs.princeton.edu/courses/archive/fall09/cos318/precepts/bochs_setup.html#:~:text=If%20you%20are%20using%20Ubuntu,via%20a%20package%20management%20system.)

## Installation Steps
```bash
# down load annd extract the bochs file, for example bochs 2.7
# enter the extracted bochs folder
# create a customized config file for compile and install bochs on your host machine
sh .conf.mylinux
# then compile the bochs
make
# install the bochs to the current os
sudo make install

# running bochs to test
bochs
```
**Runing bochs results**
```bash
========================================================================
                        Bochs x86 Emulator 2.7
              Built from SVN snapshot on August  1, 2021
                Timestamp: Sun Aug  1 10:07:00 CEST 2021
========================================================================
00000000000i[      ] BXSHARE not set. using compile time default '/usr/local/share/bochs'
00000000000i[      ] reading configuration from .bochsrc
00000000000e[      ] .bochsrc:759: ataX-master/slave CHS set to 0/0/0 - autodetection enabled
------------------------------
Bochs Configuration: Main Menu
------------------------------

This is the Bochs Configuration Interface, where you can describe the
machine that you want to simulate.  Bochs has already searched for a
configuration file (typically called bochsrc.txt) and loaded it if it
could be found.  When you are satisfied with the configuration, go
ahead and start the simulation.

You can also start bochs with the -q option to skip these menus.

1. Restore factory default configuration
2. Read options from...
3. Edit options
4. Save options to...
5. Restore the Bochs state from...
6. Begin simulation
7. Quit now

Please choose one: [6]
```

## Example setup config file
```bash
#!/bin/sh
#
# .conf.linux
#

which_config=normal
#which_config=plugins

CC="gcc"
CXX="c++"
CFLAGS="-Wall -O3 -fomit-frame-pointer -pipe"    # for speed
#CFLAGS="-Wall -g -pipe"                         # for development
CXXFLAGS="$CFLAGS"

export CC
export CXX
export CFLAGS
export CXXFLAGS


case $which_config in

  normal)

    #######################################################################
    # configuration 1 for release binary RPMs
    # Include a few standard options, speed optimizations, X11 only.
    #######################################################################
    ./configure --enable-sb16 \
                --enable-ne2000 \
                --enable-all-optimizations \
                --enable-cpu-level=6 \
                --enable-x86-64 \
                --enable-vmx=2 \
                --enable-pci \
                --enable-clgd54xx \
                --enable-voodoo \
                --enable-usb \
                --enable-usb-ohci \
                --enable-usb-ehci \
                --enable-usb-xhci \
                --enable-busmouse \
                --enable-es1370 \
                --enable-e1000 \
                --enable-show-ips \
                --enable-debugger \
                --enable-debugger-gui \
                --enable-readline \
                #--enable-gdb-stub \ # exclusive with debugger
                ${CONFIGURE_ARGS}
    ;;

  plugins)
    #######################################################################
    # configuration 2 for release binary RPMs
    # Include plugins, every possible gui.
    #######################################################################
    ./configure --enable-sb16 \
                --enable-ne2000 \
                --enable-all-optimizations \
                --enable-cpu-level=6 \
                --enable-x86-64 \
                --enable-vmx=2 \
                --enable-pci \
                --enable-clgd54xx \
                --enable-voodoo \
                --enable-usb \
                --enable-usb-ohci \
                --enable-usb-ehci \
                --enable-usb-xhci \
                --enable-busmouse \
                --enable-es1370 \
                --enable-e1000 \
                --enable-plugins \
                --enable-show-ips \
                --with-all-libs \
                ${CONFIGURE_ARGS}
    ;;

esac

```
## bochsrc
running time configuration for the bochs \
https://bochs.sourceforge.io/doc/docbook/user/bochsrc.html
```bash
  floppya: 1_44="./boot.img", status=inserted
  boot: floppy
```

# Basic Debug

If you have used the command line version of `gdb` program, then you must feel familiar when you start using the `bochs` to debug

## Break Points

To set up a break point, you need to know the address(linear logic address) of the code you want to set break point.

Below is an example of setting up a break point at address of `0c7c00`, if you are familiar with boot loader, then you would know that this address is the start point of the boot program, which means that the boot code you have written would be loaded to RAM from this address.

```
========================================================================
                        Bochs x86 Emulator 2.7
              Built from SVN snapshot on August  1, 2021
                Timestamp: Sun Aug  1 10:07:00 CEST 2021
========================================================================
00000000000i[      ] BXSHARE not set. using compile time default '/usr/local/share/bochs'
00000000000i[      ] reading configuration from ./bochsrc
------------------------------
Bochs Configuration: Main Menu
------------------------------

This is the Bochs Configuration Interface, where you can describe the
machine that you want to simulate.  Bochs has already searched for a
configuration file (typically called bochsrc.txt) and loaded it if it
could be found.  When you are satisfied with the configuration, go
ahead and start the simulation.

You can also start bochs with the -q option to skip these menus.

1. Restore factory default configuration
2. Read options from...
3. Edit options
4. Save options to...
5. Restore the Bochs state from...
6. Begin simulation
7. Quit now

Please choose one: [6] 
00000000000i[      ] installing x module as the Bochs GUI
00000000000i[      ] using log file bochs.log
Next at t=0
(0) [0x0000fffffff0] f000:fff0 (unk. ctxt): jmpf 0xf000:e05b          ; ea5be000f0
<bochs:1> b 0x7c00
<bochs:2> 
```

Then we hit **c** for continue, as we can see from below content, the program stopped at the position, then we can either debug it step by step, or just hit another **c** to run the program.

```
<bochs:1> b 0x7c00
<bochs:2> c
(0) Breakpoint 1, 0x0000000000007c00 in ?? ()
Next at t=14034559
(0) [0x000000007c00] 0000:7c00 (unk. ctxt): jmp .+60  (0x00007c3e)    ; eb3c
<bochs:3> 
```

## Show the Registers

Some times we want to see what are the parameters passed for the BIOS interrupt we invoked.

Below is an example of  debug `int13h, ah-02h`, which accepts a `CHS` format address and `ES:BX` as the destination address to read disk to the RAM. First we set up an break point, to let the program stop at `int 13h`

```
========================================================================
                        Bochs x86 Emulator 2.7
              Built from SVN snapshot on August  1, 2021
                Timestamp: Sun Aug  1 10:07:00 CEST 2021
========================================================================
00000000000i[      ] BXSHARE not set. using compile time default '/usr/local/share/bochs'
00000000000i[      ] reading configuration from ./bochsrc
------------------------------
Bochs Configuration: Main Menu
------------------------------

This is the Bochs Configuration Interface, where you can describe the
machine that you want to simulate.  Bochs has already searched for a
configuration file (typically called bochsrc.txt) and loaded it if it
could be found.  When you are satisfied with the configuration, go
ahead and start the simulation.

You can also start bochs with the -q option to skip these menus.

1. Restore factory default configuration
2. Read options from...
3. Edit options
4. Save options to...
5. Restore the Bochs state from...
6. Begin simulation
7. Quit now

Please choose one: [6] 
00000000000i[      ] installing x module as the Bochs GUI
00000000000i[      ] using log file bochs.log
cNext at t=0
(0) [0x0000fffffff0] f000:fff0 (unk. ctxt): jmpf 0xf000:e05b          ; ea5be000f0
<bochs:1> b 0x7cb8
<bochs:2> c
(0) Breakpoint 1, 0x0000000000007cb8 in ?? ()
Next at t=14048253
(0) [0x000000007cb8] 0000:7cb8 (unk. ctxt): int 0x13                  ; cd13
<bochs:3> 
```

Now we can type the following commands to show the registers

```
<bochs:3> r
rax: 00000000_00000201
rbx: 00000000_00000000
rcx: 00000000_00090002
rdx: 00000000_00000100
rsp: 00000000_00007bf8
rbp: 00000000_00007bfa
rsi: 00000000_000e0000
rdi: 00000000_0000ffac
r8 : 00000000_00000000
r9 : 00000000_00000000
r10: 00000000_00000000
r11: 00000000_00000000
r12: 00000000_00000000
r13: 00000000_00000000
r14: 00000000_00000000
r15: 00000000_00000000
rip: 00000000_00007cb8
eflags 0x00000002: id vip vif ac vm rf nt IOPL=0 of df if tf sf zf af pf cf

```

```
<bochs:4> info cpu
rax: 00000000_00000201
rbx: 00000000_00000000
rcx: 00000000_00090002
rdx: 00000000_00000100
rsp: 00000000_00007bf8
rbp: 00000000_00007bfa
rsi: 00000000_000e0000
rdi: 00000000_0000ffac
r8 : 00000000_00000000
r9 : 00000000_00000000
r10: 00000000_00000000
r11: 00000000_00000000
r12: 00000000_00000000
r13: 00000000_00000000
r14: 00000000_00000000
r15: 00000000_00000000
rip: 00000000_00007cb8
eflags 0x00000002: id vip vif ac vm rf nt IOPL=0 of df if tf sf zf af pf cf
status  word: 0x0000: b c3 TOS0 c2 c1 c0 es sf pe ue oe ze de ie
control word: 0x0040: inf RC_NEAREST PC_32 pm um om zm dm im
tag word:     0x5555
operand:      0x0000
fip:          0x0000000000000000
fcs:          0x0000
fdp:          0x0000000000000000
fds:          0x0000
=>FP0 ST0(0):        raw 0x0000:0000000000000000 (0.0000000000) (ZERO)
  FP1 ST1(0):        raw 0x0000:0000000000000000 (0.0000000000) (ZERO)
  FP2 ST2(0):        raw 0x0000:0000000000000000 (0.0000000000) (ZERO)
  FP3 ST3(0):        raw 0x0000:0000000000000000 (0.0000000000) (ZERO)
  FP4 ST4(0):        raw 0x0000:0000000000000000 (0.0000000000) (ZERO)
  FP5 ST5(0):        raw 0x0000:0000000000000000 (0.0000000000) (ZERO)
  FP6 ST6(0):        raw 0x0000:0000000000000000 (0.0000000000) (ZERO)
  FP7 ST7(0):        raw 0x0000:0000000000000000 (0.0000000000) (ZERO)
MM[0]: 00000000_00000000
MM[1]: 00000000_00000000
MM[2]: 00000000_00000000
MM[3]: 00000000_00000000
MM[4]: 00000000_00000000
MM[5]: 00000000_00000000
MM[6]: 00000000_00000000
MM[7]: 00000000_00000000
MXCSR: 0x01f80: ule fuz RC:Nearest PM UM OM ZM DM IM daz pe ue oe ze de ie
XMM[00]: 00000000_00000000_00000000_00000000
XMM[01]: 00000000_00000000_00000000_00000000
XMM[02]: 00000000_00000000_00000000_00000000
XMM[03]: 00000000_00000000_00000000_00000000
XMM[04]: 00000000_00000000_00000000_00000000
XMM[05]: 00000000_00000000_00000000_00000000
XMM[06]: 00000000_00000000_00000000_00000000
XMM[07]: 00000000_00000000_00000000_00000000
XMM[08]: 00000000_00000000_00000000_00000000
XMM[09]: 00000000_00000000_00000000_00000000
XMM[10]: 00000000_00000000_00000000_00000000
XMM[11]: 00000000_00000000_00000000_00000000
XMM[12]: 00000000_00000000_00000000_00000000
XMM[13]: 00000000_00000000_00000000_00000000
XMM[14]: 00000000_00000000_00000000_00000000
XMM[15]: 00000000_00000000_00000000_00000000
<bochs:5> 

```

## Modify the Registers

Sometimes, we want to modify the values of some registers so that we can see if we are right about some bug.

Followed with the debug process of `int 13h ah=02h` from above, we can get the registers as follow:

```
(0) [0x000000007cb8] 0000:7cb8 (unk. ctxt): int 0x13                  ; cd13
<bochs:3> r
rax: 00000000_00000201
rbx: 00000000_00000000
rcx: 00000000_00090002
rdx: 00000000_00000100
rsp: 00000000_00007bf8
rbp: 00000000_00007bfa
rsi: 00000000_000e0000
rdi: 00000000_0000ffac
r8 : 00000000_00000000
r9 : 00000000_00000000
r10: 00000000_00000000
r11: 00000000_00000000
r12: 00000000_00000000
r13: 00000000_00000000
r14: 00000000_00000000
r15: 00000000_00000000
rip: 00000000_00007cb8
eflags 0x00000002: id vip vif ac vm rf nt IOPL=0 of df if tf sf zf af pf cf
```

Which means that we are loading the sector designated by `Cylinder=0, Head=1, Sector=2`, however, we can modify the register `cx` to value of `0x0001` to modify the `Sector` to value of `1`

```
<bochs:5> r
......
rcx: 00000000_00090002
......
<bochs:6> set cx=0x0001
<bochs:7> r
......
rcx: 00000000_00090001
......
```

then we can type **c** for continue to see the results.

**Note:**

Not all registers can be modified, for example, the error flags registers can not be modified.

For further information, please reach out for the bochs manual.

# References

https://iitd-plos.github.io/os/2020/previous_years/2014/bochs/internal-debugger.html#:~:text=set%20reg%20%3D%20expr%20Change%20a%20CPU%20register,CPU%20registers%20and%20their%20contents%20regs%20reg%20r

https://en.wikipedia.org/wiki/INT_13H

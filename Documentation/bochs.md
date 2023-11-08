## Bochs
Using bochs as a virtual environment for the operating system before migrating to the actual machine. \
https://github.com/bochs-emu/Bochs \
https://bochs.sourceforge.io/ \
[Install Guide](https://www.cs.princeton.edu/courses/archive/fall09/cos318/precepts/bochs_setup.html#:~:text=If%20you%20are%20using%20Ubuntu,via%20a%20package%20management%20system.)

### Installation Steps
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

### Example setup config file
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

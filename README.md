# Porting applications for the ctOS operating system

## What is ctOS?

[ctOS](https://www.github.com/christianb93/ctOS) is a 32-bit hobbyist operating system, designed and built for fun and to understand the inner workings of a Unix-like operating system. This is not the actual home of ctOS - which is living in its own [Github repository](https://www.github.com/christianb93/ctOS) - but it contains patches and scripts that are needed to port some applications that you might know from your Linux system to ctOS.

## What this repository contains

This repository contains a collection of patches and script to ease and automate the creation of a userland for ctOS. No documentation on the invididual patches is provided, please see the [ctOS Porting Guide](https://github.com/christianb93/ctOS/blob/master/doc/system/PortingGuide.md) for details.

The ports contained in this repository are twofold.

First, there is a **GCC based toolchain**. This are versions of tools like the GNU assembler, the GNU dynamic linker and the GNU C compiler GCC that are able to link against the ctOS runtime library and to emit code running on ctOS

Then, there are the actual applications and libraries which are patched versions of standard open source tools. At the moment, the following ports can be found here.

* dash - the Debian Almquist POSIX compatible shell
* elvis - a VI clone
* ncurses - a version of the curses library to control text based terminals
* wget - this has been added as a showcase for the ctOS TCP/IP stack and allows you to download files from the web
* coreutils - I haved ported a subset of the coreutils (ls, echo, cat, env, ....) to ctOS

## Prerequisites

To build everything, there are some preparations needed. First, you need to get and build a version of ctOS itself, as we will need access to some of its header files and libraries. Assuming that you have a working copy of GCC (I have used version 5.4.0) and the corresponding standard utilities on your PC, you can download and build ctOS as follows.

```
git clone https://www.github.com/christianb93/ctOS.git
cd ctOS
make
```

This will create a directory called ctOS. If, for instance, you did execute the commands above in your home directory, this will be `$HOME/ctOS`. 

Next, we need to define our directory structure. The build needs two directories.

* First, there is the **ctOS root directory**. This is the directory that you just created. To make this known to the build scripts, please set the environment variable CTOS_ROOT. So in the example above, you would do `export CTOS_ROOT=$HOME/ctOS`.
* Then, we need to create a (separate!) **build directory** which will hold all the sources and binaries and will act as the root directory for the GCC/binutils toolchain. You can choose whatever director you like. For the purpose of this guide, assume that you want to use `$HOME/ctOS_sys`. Please make sure that this directory exists and is empty, and then make it known to the build tools by setting CTOS_PREFIX, i.e. in this case `export CTOS_PREFIX=$HOME/ctOS_sys`. 

Make sure that you have some space left, the build directory will consume roughly 3 GB on your hard disk (but of course you can clean up the sources once the build is complete).

Finally, there are a couple of packages that binutils and GCC will need to build. To get all those packages on an Ubuntu system, use

```
sudo apt-get install texinfo flex bison libgmp-dev libmpc-de
```

## Running all builds automatically

Now you are ready to run all builds. Ensure that you have the environment variables CTOS_ROOT and CTOS_PREFIX set as described above, a simple

```
git clone https://www.github.com/christianb93/ctOS_ports
cd ctOS_ports
./build_all.sh
```

will do the job. The script will first check whether all environment variables are set and print out the directories that it is going to use, which you will have to confirm. Then it will download and install everything from scratch. If you need a cup of coffee get it now - this can take between 30 minutes and an hour depending on your build system. 

When the builds are complete, you will find all created executables in $CTOS_ROOT/bin/import/bin. To build a ctOS hard disk image that contains these executables and start ctOS on QEMU, now do (please find a full documentation of how to run ctOS in its [main repository](https://www.github.com/christianb93/ctOS))

```
cd $CTOS_ROOT/bin
./init_images.sh
cd ..
./bin/run.sh 
```


## Building individual applications

Of course you can also build the applications individually at each point in time, as long as you respect the dependencies (you will always have to build binutils first, then GCC and then any other applications, you will also have to build a library that an application needs before you can build that application). 

To do this, simply set the environment variables CTOS_PREFIX and CTOS_ROOT as above and execute the build scripts found in each subdirectory of the GIT repo. So, for instance, to build dash, simply run the script `dash/build_dash.sh`.





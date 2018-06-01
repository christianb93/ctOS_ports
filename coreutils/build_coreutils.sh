#!/bin/bash
#
# This script will download the source code of coreutils 
# and apply the needed patches to adapt them for ctOS as a target
#
# This script will build in $CTOS_PREFIX/build and install in 
# $CTOS_PREFIX/sysroot. The patched source code will be placed in
# $CTOS_PREFIX/src
#
# Note that only a very small selected subset will be built
#


#
# Check whether we have defined CTOS_PREFIX
#
if [ "x$CTOS_PREFIX" = "x" ]
then
  echo "It seems that the environment variable CTOS_PREFIX is not set"
  echo "This variable would tell me where I will be building and installing"
  echo "Please make CTOS_PREFIX point to an existing directory and try again"
  exit
fi

if [ ! -d "$CTOS_PREFIX" ]
then
  echo "The directory $CTOS_PREFIX does not seem to exist"
  echo "Please create it or adjust CTOS_PREFIX"
  exit
fi

if [ ! -e "$CTOS_PREFIX/sysroot/bin/i686-pc-ctOS-gcc" ]
then
  echo "Are you sure that CTOS_PREFIX is set correctly and that you "
  echo "have successfully built GCC there?"
  echo "I did expect to find $CTOS_PREFIX/sysroot/bin/i686-pc-ctOS-gcc"
  exit
fi


echo "Building a selected subset of coreutils for ctOS"
echo "-------------------------------------------------------------------"
echo "I will use the following directories:"
echo "Patched source will be placed in $CTOS_PREFIX/src/"
echo "I will build in                  $CTOS_PREFIX/build"
echo "I will install in                $CTOS_PREFIX/sysroot"
echo "Sysroot will be                  $CTOS_PREFIX/sysroot"
echo "All directories will be created if they do not exist yet"
if [ "x$CTOS_BUILD_CONFIRM" = "x" ]
then
    read -p "Ok and proceed? (Y/n): "
    if [ "$REPLY" != "Y" ] ; then
        echo "Exiting, but you can restart at any point in time."
        exit
    fi
fi

PATCH_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

#
# Get sources and apply patches
#
echo "Getting sources"
cd $CTOS_PREFIX
mkdir -p src
cd src
if [ ! -e "coreutils_8.13.orig.tar" ]
then
    wget http://ubuntu-master.mirror.tudos.de/ubuntu/pool/main/c/coreutils/coreutils_8.13.orig.tar.gz
    gzip -d coreutils_8.13.orig.tar.gz
fi
tar xvf coreutils_8.13.orig.tar
patch -p0 < $PATCH_DIR/coreutils.patch

#
# Running actual build
#
echo "Doing actual build"
export PATH=$PATH:$CTOS_PREFIX/sysroot/bin/
mkdir -p $CTOS_PREFIX/build/coreutils
cd $CTOS_PREFIX/build/coreutils
../../src/coreutils-8.13/configure --host=i686-pc-ctOS
(cd lib ; make)
(cd src ; make dircolors.h wheel-size.h wheel.h fs.h version.c version.h)
(cd src; make ls cp cat echo env printenv dir)
echo "-------------------------------------------------------------------"
echo "Done, look for executables in $CTOS_PREFIX/build/coreutils/src"
if [ ! "x$CTOS_ROOT" = "x" ]
then
  mkdir -p $CTOS_ROOT/bin/import/bin
  (cd $CTOS_PREFIX/build/coreutils/src; cp -v ls  dir cp cat echo env printenv $CTOS_ROOT/bin/import/bin)
  echo "I did also copy some files to $CTOS_ROOT/bin/import/bin for you"
  exit
fi
echo "-------------------------------------------------------------------"



#!/bin/bash
#
# This script will download the source code of GCC 
# and apply the needed patches to adapt them for ctOS as a target
#
# This script will build in $CTOS_PREFIX/build and install in 
# $CTOS_PREFIX/sysroot. The patched source code will be placed in
# $CTOS_PREFIX/src
#
# We also need CTOS_ROOT to point to a clone of the actual ctOS
# repository in which a build has been done
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

if [ "x$CTOS_ROOT" = "x" ]
then
  echo "It seems that the environment variable CTOS_ROOT is not set"
  echo "Please make CTOS_ROOT point to an existing clone of the ctOS"
  echo "repository (see github.com/christianb93/ctOS) in which a build"
  echo "has been done as I need to get some header files and libraries"
  echo "from there."
  exit
fi

if [ ! -e "$CTOS_ROOT/lib/std/crt0.o" ]
then
  echo "Are you sure that CTOS_ROOT is set correctly and that you "
  echo "have built ctOS there?"
  echo "I did expect to find $CTOS_ROOT/lib/std/crt0.o"
  exit
fi


echo "Building GCC for ctOS"
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

PATCH_DIR=$(dirname "$0")

#
# Get sources and apply patches
#
cd $CTOS_PREFIX
mkdir -p src
mkdir -p sysroot
cd src
if [ ! -e "gcc-5.4.0.tar" ]
then
    wget https://ftpmirror.gnu.org/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz
    gzip -d gcc-5.4.0.tar.gz
fi
tar xvf gcc-5.4.0.tar  
patch -p0 < $PATCH_DIR/gcc.patch
cp $PATCH_DIR/ctOS.h $CTOS_PREFIX/src/gcc-5.4.0/gcc/config/i386/ctOS.h

#
# Preparing build
#
mkdir -p $CTOS_PREFIX/sysroot/usr/include
cp -v  $CTOS_ROOT/include/lib/*.h $CTOS_PREFIX/sysroot/usr/include/
mkdir -p $CTOS_PREFIX/sysroot/usr/include/os/
mkdir -p $CTOS_PREFIX/sysroot/usr/include/sys/
mkdir -p $CTOS_PREFIX/sysroot/usr/include/netinet
mkdir -p $CTOS_PREFIX/sysroot/usr/include/arpa
cp -v $CTOS_ROOT/include/lib/os/*.h $CTOS_PREFIX/sysroot/usr/include/os/
cp -v $CTOS_ROOT/include/lib/sys/*.h $CTOS_PREFIX/sysroot/usr/include/sys/
cp -v $CTOS_ROOT/include/lib/netinet/*.h $CTOS_PREFIX/sysroot/usr/include/netinet
cp -v $CTOS_ROOT/include/lib/arpa/*.h $CTOS_PREFIX/sysroot/usr/include/arpa
mkdir -p $CTOS_PREFIX/sysroot/lib/
cp -v $CTOS_ROOT/lib/std/crt0.o $CTOS_PREFIX/sysroot/lib/
cp -v $CTOS_ROOT/lib/std/crti.o $CTOS_PREFIX/sysroot/lib/
cp -v $CTOS_ROOT/lib/std/crtn.o $CTOS_PREFIX/sysroot/lib/
cp -v $CTOS_ROOT/lib/std/libc.a $CTOS_PREFIX/sysroot/lib/


#
# Running actual build
#
cd $CTOS_PREFIX
mkdir -p build/gcc
cd build/gcc
../../src/gcc-5.4.0/configure --target=i686-pc-ctOS --prefix=$CTOS_PREFIX/sysroot --with-sysroot=$CTOS_PREFIX/sysroot --with-gnu-as --with-gnu-ld --enable-languages=c 
make -j 4
make install
echo "-------------------------------------------------------------------"
echo "Done"
echo "-------------------------------------------------------------------"

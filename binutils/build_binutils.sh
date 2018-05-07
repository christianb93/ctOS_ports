#!/bin/bash
#
# This script will download the source code of the GNU binutils 
# and apply the needed patches to adapt them for ctOS as a target
#
# This script will build in $CTOS_PREFIX/build and install in 
# $CTOS_PREFIX/sysroot. The patched source code will be placed in
# $CTOS_PREFIX/src
#

#
# Check whether we have defined CTOS_PREFIX
#
if [ "x$CTOS_PREFIX" = "x" ]
then
  echo "It seems that the environment variable CTOS_PREFIX is not set"
  echo "This variable would tell me where I will be building and installing"
  echo "Please make CTOS_PREFIX point to an existing directory and try again"
  echo "I personally use CTOS_PREFIX=$HOME/ctOS_sys"
  exit
fi

if [ ! -d "$CTOS_PREFIX" ]
then
  echo "The directory $CTOS_PREFIX does not seem to exist"
  echo "Please create it or adjust CTOS_PREFIX"
  exit
fi

echo "Building binutils for ctOS"
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
cd $CTOS_PREFIX
mkdir -p src
mkdir -p sysroot
cd src
if [ ! -e "binutils-2.27.tar" ]
then
    wget https://ftpmirror.gnu.org/binutils/binutils-2.27.tar.gz
    gzip -d binutils-2.27.tar.gz
fi
tar xvf binutils-2.27.tar  
patch -p0 < $PATCH_DIR/binutils.patch
cd ..
mkdir -p build/binutils
cd build/binutils
../../src/binutils-2.27/configure --target=i686-pc-ctOS --prefix=$CTOS_PREFIX/sysroot --with-sysroot=/$CTOS_PREFIX/sysroot
make
make install

echo "-------------------------------------------------------------------"
echo "Done"
echo "-------------------------------------------------------------------"

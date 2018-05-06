#!/bin/bash
#
# This script will download the source code of ncurses 
# and apply the needed patches to adapt them for ctOS as a target
# We assume that we are on a system where apt-get source is available
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
  echo "have successfully GCC there?"
  echo "I did expect to find $CTOS_PREFIX/sysroot/bin/i686-pc-ctOS-gcc"
  exit
fi


echo "Building ncurses for ctOS"
echo "-------------------------------------------------------------------"
echo "I will use the following directories:"
echo "Patched source will be placed in $CTOS_PREFIX/src/"
echo "I will build in                  $CTOS_PREFIX/build"
echo "I will install in                $CTOS_PREFIX/sysroot"
echo "Sysroot will be                  $CTOS_PREFIX/sysroot"
echo "All directories will be created if they do not exist yet"
read -p "Ok and proceed? (Y/n): "
if [ "$REPLY" != "Y" ] ; then
    echo "Exiting, but you can restart at any point in time."
    exit
fi

PATCH_DIR=$(dirname "$0")

#
# Get sources and apply patches
#
echo "Getting sources"
cd $CTOS_PREFIX
mkdir -p src
cd src
#
# We use GIT to clone into a specific branch, on a Debian machine,
#   apt-get source ncurses
# would also work
#
git clone https://anonscm.debian.org/git/collab-maint/ncurses.git --branch upstream/6.0+20160213 --single-branch
mv ncurses ncurses-6.0+20160213
patch -p0 < $PATCH_DIR/ncurses.patch

#
# Running actual build
#
echo "Doing actual build"
export PATH=$PATH:$CTOS_PREFIX/sysroot/bin/
cd $CTOS_PREFIX
mkdir -p build/ncurses
cd build/ncurses
../../src/ncurses-6.0+20160213/configure --disable-database --with-fallbacks=vt100,ctos --includedir=$CTOS_PREFIX/sysroot/usr/include --without-progs --without-tests --without-cxx-binding --without-ada --prefix=$CTOS_PREFIX/sysroot/ --host=i686-pc-ctOS 
make -j 4
echo "Build completed, now doing make install"
make install
echo "-------------------------------------------------------------------"
echo "Done"
echo "-------------------------------------------------------------------"

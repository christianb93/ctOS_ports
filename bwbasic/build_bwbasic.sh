#!/bin/bash
#
# This script will download the source code of Bywater basic
# and apply the needed patches to adapt them for ctOS as a target
#
# This script will build in $CTOS_PREFIX/build and install in 
# $CTOS_PREFIX/sysroot. The patched source code will be placed in
# $CTOS_PREFIX/src
#
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


echo "Building Bywater Basic for ctOS"
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
# Prepare sources 
#
echo "Getting sources"
cd $CTOS_PREFIX
mkdir -p src
cd src
if [ ! -e "bwbasic-3.20.zip" ]
then
    echo "Please go to https://sourceforge.net/projects/bwbasic/, get version 3.20 of Bywater basic (bwbasic-3.20.zip) from there and copy it to $CTOS_PREFIX/src"
    exit
fi
mkdir -p bwbasic
cd bwbasic
unzip -o ../bwbasic-3.20.zip

#
# Running actual build
#
echo "Doing actual build"
export PATH=$PATH:$CTOS_PREFIX/sysroot/bin/
mkdir -p $CTOS_PREFIX/build/bwbasic
cd $CTOS_PREFIX/build/bwbasic
chmod 700 ../../src/bwbasic/configure
dos2unix ../../src/bwbasic/configure
CC=i686-pc-ctOS-gcc  ../../src/bwbasic/configure --host=i686-pc-ctOS
make bwbasic
echo "-------------------------------------------------------------------"
echo "Done, look for executables in $CTOS_PREFIX/build/bwbasic"
if [ ! "x$CTOS_ROOT" = "x" ]
then
  mkdir -p $CTOS_ROOT/bin/import/bin
  cp -v bwbasic $CTOS_ROOT/bin/import/bin/
  echo "I did also copy some files to $CTOS_ROOT/bin/import/bin for you"
  exit
fi
echo "-------------------------------------------------------------------"



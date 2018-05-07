#!/bin/bash
#
# This script will build all ports sequentially. 
# All builds will run in $CTOS_PREFIX/build and install in 
# $CTOS_PREFIX/sysroot. The patched source code will be placed in
# $CTOS_PREFIX/src
#
# We also need CTOS_ROOT to point to a clone of the actual ctOS
# repository in which a build has been done.
#
# See the README.md in
#
#  www.github.com/christianb93/ctOS
#
# for more on ctOS and instructions on how to get and build it
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


echo "Building toolchain and ports for ctOS"
echo "-------------------------------------------------------------------"
echo "I will use the following directories:"
echo "Patched source will be placed in $CTOS_PREFIX/src/"
echo "I will build in                  $CTOS_PREFIX/build"
echo "I will install in                $CTOS_PREFIX/sysroot"
echo "Sysroot will be                  $CTOS_PREFIX/sysroot"
echo "All directories will be created if they do not exist yet"
echo "This might take some time, expect up to an hour for all"
echo "downloads and builds, depending on your machine"
read -p "Ok and proceed? (Y/n): "
if [ "$REPLY" != "Y" ] ; then
    echo "Exiting, but you can restart at any point in time."
    exit
fi

#
# Running all builds. We always start with binutils and GCC
#

REPO_DIR=$(dirname "$0")

echo "Using REPO_DIR=$REPO_DIR"
export CTOS_PREFIX
export CTOS_ROOT
export CTOS_BUILD_CONFIRM="Y"
$REPO_DIR/binutils/build_binutils.sh
$REPO_DIR/gcc/build_gcc.sh

#
# Now we do the actual ports
#
$REPO_DIR/dash/build_dash.sh
$REPO_DIR/ncurses/build_ncurses.sh
$REPO_DIR/elvis/build_elvis.sh
$REPO_DIR/wget/build_wget.sh


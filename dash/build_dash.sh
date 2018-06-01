#!/bin/bash
#
# This script will download the source code of dash 
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


echo "Building dash for ctOS"
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
#
# We get the source code directly from the location
# mentioned in the dsc file of the Debian source package
# for dash 0.5.8. If you are yourself running on a Debian derived
# system, you could also do apt-get source dash=0.5.8 after adding
# the source repository to your /etc/apt/sources.list
# This will give you the version with the Debian patches that worked
# for me as well
#
wget http://gondor.apana.org.au/~herbert/dash/files/dash-0.5.8.tar.gz
gzip -d dash-0.5.8.tar.gz
tar xvf dash-0.5.8.tar
patch -p0 < $PATCH_DIR/dash.patch

#
# Running actual build
#
echo "Doing actual build"
export PATH=$PATH:$CTOS_PREFIX/sysroot/bin/
cd $CTOS_PREFIX
mkdir -p build/dash
cd build/dash
../../src/dash-0.5.8/configure --host=i686-pc-ctOS --prefix=$CTOS_PREFIX/sysroot 
make 
echo "-------------------------------------------------------------------"
echo "Done, executable dash should be in $CTOS_PREFIX/build/dash/src"
if [ ! "x$CTOS_ROOT" = "x" ]
then
  mkdir -p $CTOS_ROOT/bin/import/bin
  cp -v $CTOS_PREFIX/build/dash/src/dash $CTOS_ROOT/bin/import/bin
  echo "I did also copy that to $CTOS_ROOT/bin/import/bin for you"
  exit
fi

echo "-------------------------------------------------------------------"

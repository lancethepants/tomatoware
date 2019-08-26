#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=$BASE/src
PATCHES=$BASE/patches
RPATH=$PREFIX/lib
DEST=$BASE$PREFIX
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
CPPFLAGS="-I$DEST/include"
CFLAGS=$EXTRACFLAGS
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=$PREFIX --host=$DESTARCH-linux"
MAKE="make -j`nproc`"
export PATH=$BASE/native/bin:$PATH

GCC_VERSION=9.1.0
NINJA_VERSION=1.9.0
CMAKE_VERSION=3.15.2
CCACHE_VERSION=3.7.1

if [ "$DESTARCH" = "arm" ]; then
        GNUEABI=gnueabi
fi

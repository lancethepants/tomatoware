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
ORIGINALPATH=$PATH
export PATH=$BASE/native/bin:$PATH

BINUTILS_VERSION=2.33.1
GCC_VERSION=9.3.0
NINJA_VERSION=1.10.0
CMAKE_VERSION=3.17.2
CCACHE_VERSION=3.7.9

if [ "$DESTARCH" = "arm" ]; then
	GNUEABI=gnueabi
	MIPSEL=mipsel-buildroot-linux-uclibc
fi

if [ "$BUILDLLVM" == "1" ] && [ "$DESTARCH" == "arm" ]; then
	GCCforClang="5.1.0"
	if [ ! "$(printf '%s\n' "$GCCforClang" "$(g++ -dumpversion)" | sort -V | head -n1)" = "$GCCforClang" ]; then
		BUILDHOSTGCC=1
	fi
fi

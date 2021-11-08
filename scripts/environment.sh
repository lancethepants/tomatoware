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
export CCACHE_DIR=$HOME/.ccache

PERL_VERSION=5.34.0
BINUTILS_VERSION=2.37
GCC_VERSION=11.2.0
NINJA_VERSION=1.10.2
CMAKE_VERSION=3.21.4
CCACHE_VERSION=4.4.1

if [ "$DESTARCH" = "arm" ]; then
	GNUEABI=gnueabi
	if [ "$BUILDCROSSTOOLS" == "1" ]; then
		MIPSEL=mipsel-tomatoware-linux-uclibc
	fi
fi

if [ "$BUILDLLVM" == "1" ] && [ "$DESTARCH" == "arm" ]; then
	GCCforClang="5.1.0"
	if [ ! "$(printf '%s\n' "$GCCforClang" "$(g++ -dumpversion)" | sort -V | head -n1)" = "$GCCforClang" ]; then
		BUILDHOSTGCC=1
	fi
fi

Status () {
	echo -e '\033]2;'compiling $1'\007'
}

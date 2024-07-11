#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=$BASE/src
PATCHES=$BASE/patches
DEST=$BASE$PREFIX
CPPFLAGS="-I$DEST/include"
CFLAGS=$EXTRACFLAGS
CXXFLAGS=$CFLAGS

MAKE1="make"
MAKE="make -j`nproc`"
NINJA="ninja"

ORIGINALPATH=$PATH
export PATH=$BASE/native/bin:$PATH
export CCACHE_DIR=$HOME/.ccache

if [ "$DESTARCHLIBC" == "uclibc" ]; then
	LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 -Wl,-rpath-link,$DEST/lib"
	if [ "$DESTARCH" = "arm" ]; then
		EABI=gnueabi
		if [ "$BUILDCROSSTOOLS" == "1" ]; then
			MIPSEL=mipsel-tomatoware-linux-uclibc
		fi
	fi
fi

if [ "$DESTARCHLIBC" == "musl" ]; then
	LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-musl-$DESTARCH.so.1 -Wl,-rpath-link,$DEST/lib"
	if [ "$DESTARCH" = "arm" ]; then
		EABI=eabi
	fi
fi

CONFIGURE="./configure --prefix=$PREFIX --host=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI"
export LT_SYS_LIBRARY_PATH="$PREFIX/lib $DEST/lib /opt/tomatoware/$DESTARCH-$DESTARCHLIBC${PREFIX////-}/$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI/lib"

BINUTILS_VERSION=2.42
GCC_VERSION=14.1.0
NINJA_VERSION=1.12.1
CMAKE_VERSION=3.30.0
CCACHE_VERSION=4.10.1
AUTOCONF_VERSION=2.71

if [ "$DESTARCH" == "aarch64" ]; then
	PERL_VERSION=5.32.1
else
	PERL_VERSION=5.40.0
fi

if [ "$BUILDLLVM" == "1" ] && [ "$DESTARCH" == "arm" ]; then
	GCCforClang="5.1.0"
	if [ ! "$(printf '%s\n' "$GCCforClang" "$(g++ -dumpversion)" | sort -V | head -n1)" = "$GCCforClang" ]; then
		BUILDHOSTGCC=1
	fi
fi

Status () {
	declare COUNT=$(cat "$BASE/.count")
	COUNT=$((COUNT+1))
	echo "$COUNT" > $BASE/.count
	TOTAL=$(grep -o "Status" $BASE/scripts/* --exclude=environment.sh | wc -l)
	echo -e '\033]2;'$COUNT/$TOTAL - $1'\007'
}

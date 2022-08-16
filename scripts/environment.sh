#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=$BASE/src
PATCHES=$BASE/patches
DEST=$BASE$PREFIX

if [ "$DESTARCHLIBC" == "uclibc" ]; then
	LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 -Wl,-rpath-link,$DEST/lib"
fi

if [ "$DESTARCHLIBC" == "musl" ]; then
        LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-musl-aarch64.so.1 -Wl,-rpath-link,$DEST/lib"
fi

CPPFLAGS="-I$DEST/include"
CFLAGS=$EXTRACFLAGS
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=$PREFIX --host=$DESTARCH-linux"
MAKE1="make"
MAKE="make -j`nproc`"
NINJA="ninja"
ORIGINALPATH=$PATH
export PATH=$BASE/native/bin:$PATH
export CCACHE_DIR=$HOME/.ccache
export LT_SYS_LIBRARY_PATH="$PREFIX/lib $DEST/lib /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/lib"

if [ "$DESTARCH" == "aarch64" ]; then
	PERL_VERSION=5.32.1
else
	PERL_VERSION=5.36.0
fi

BINUTILS_VERSION=2.38
GCC_VERSION=12.1.0
NINJA_VERSION=1.11.0
CMAKE_VERSION=3.23.3
CCACHE_VERSION=4.6.1

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
	declare COUNT=$(cat "$BASE/.count")
	COUNT=$((COUNT+1))
	echo "$COUNT" > $BASE/.count
	TOTAL=$(grep -o "Status" $BASE/scripts/* --exclude=environment.sh | wc -l)
	echo -e '\033]2;'$COUNT/$TOTAL - $1'\007'
}

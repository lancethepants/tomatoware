#!/bin/bash

set -e
set -x

source ./scripts/environment.sh

########## ##################################################################
# CCACHE # ##################################################################
########## ##################################################################

CCACHE_VERSION=3.7.1

cd $SRC/ccache

if [ ! -f .extracted-native ]; then
        rm -rf ccache-${CCACHE_VERSION} ccache-${CCACHE_VERSION}-native
        tar xvJf ccache-${CCACHE_VERSION}.tar.xz
        mv ccache-${CCACHE_VERSION} ccache-${CCACHE_VERSION}-native
        touch .extracted-native
fi

cd ccache-${CCACHE_VERSION}-native

if [ ! -f .built-native ]; then
        ./configure \
        --prefix=$BASE/native
        $MAKE
        make install
        touch .built-native
fi

if [ ! -f .symlinked ]; then
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-c++
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-cc
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-g++
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-gcc
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-gcc-$GCC_VERSION
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibc$GNUEABI-c++
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibc$GNUEABI-cc
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibc$GNUEABI-g++
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibc$GNUEABI-gcc
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibc$GNUEABI-gcc-$GCC_VERSION

	ln -sf ccache $BASE/native/bin/cc
	ln -sf ccache $BASE/native/bin/gcc
	ln -sf ccache $BASE/native/bin/c++
	ln -sf ccache $BASE/native/bin/g++
	touch .symlinked
fi

######### ###################################################################
# NINJA # ###################################################################
######### ###################################################################

cd $SRC/ninja

if [ ! -f .extracted-native ]; then
        rm -rf ninja-${NINJA_VERSION} ninja-${NINJA_VERSION}-native
        tar zxvf ninja-v${NINJA_VERSION}.tar.gz
        mv ninja-${NINJA_VERSION} ninja-${NINJA_VERSION}-native
        touch .extracted-native
fi

cd ninja-${NINJA_VERSION}-native

if [ ! -f .built-native ]; then
        python ./configure.py --bootstrap
	mkdir -p $BASE/native/bin
	cp ninja $BASE/native/bin
        touch .built-native
fi

######### ###################################################################
# CMAKE # ###################################################################
######### ###################################################################

cd $SRC/cmake

if [ ! -f .extracted-native ]; then
        rm -rf cmake-${CMAKE_VERSION} cmake-${CMAKE_VERSION}-native
        tar zxvf cmake-${CMAKE_VERSION}.tar.gz
        mv cmake-${CMAKE_VERSION} cmake-${CMAKE_VERSION}-native
        touch .extracted-native
fi

cd cmake-${CMAKE_VERSION}-native

if [ ! -f .built-native ]; then
        ./configure \
        --prefix=$BASE/native
        $MAKE
        make install
        touch .built-native
fi

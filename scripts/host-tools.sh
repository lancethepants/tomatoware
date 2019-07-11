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
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-gcc-9.1.0
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibcgnueabi-c++
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibcgnueabi-cc
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibcgnueabi-g++
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibcgnueabi-gcc
	ln -sf ccache $BASE/native/bin/$DESTARCH-buildroot-linux-uclibcgnueabi-gcc-9.1

	ln -sf ccache $BASE/native/bin/cc
	ln -sf ccache $BASE/native/bin/gcc
	ln -sf ccache $BASE/native/bin/c++
	ln -sf ccache $BASE/native/bin/g++
	touch .symlinked
fi

######### ###################################################################
# NINJA # ###################################################################
######### ###################################################################

NINJA_VERSION=1.9.0

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

CMAKE_VERSION=3.14.4

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

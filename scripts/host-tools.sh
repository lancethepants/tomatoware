#!/bin/bash

source ./scripts/environment.sh

############### #############################################################
# CCACHE-LINK # #############################################################
############### #############################################################
Status "Setting up ccache-link"

install -D $SRC/ccache/ccache-bin $BASE/native/bin/ccache

if [ ! -f .symlinked-native ]; then

	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-c++
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-cc
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-g++
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-gcc
	ln -sf ccache $BASE/native/bin/$DESTARCH-linux-gcc-$GCC_VERSION
	ln -sf ccache $BASE/native/bin/$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-c++
	ln -sf ccache $BASE/native/bin/$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-cc
	ln -sf ccache $BASE/native/bin/$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++
	ln -sf ccache $BASE/native/bin/$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc
	ln -sf ccache $BASE/native/bin/$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc-$GCC_VERSION

	ln -sf ccache $BASE/native/bin/cc
	ln -sf ccache $BASE/native/bin/gcc
	ln -sf ccache $BASE/native/bin/c++
	ln -sf ccache $BASE/native/bin/g++

	if [ "$DESTARCH" == "arm" ] && [ "$DESTARCHLIBC" == "uclibc" ] && [ "$BUILDCROSSTOOLS" == "1" ]; then

		ln -sf ccache $BASE/native/bin/mipsel-linux-c++
		ln -sf ccache $BASE/native/bin/mipsel-linux-cc
		ln -sf ccache $BASE/native/bin/mipsel-linux-g++
		ln -sf ccache $BASE/native/bin/mipsel-linux-gcc

		ln -sf ccache $BASE/native/bin/mipsel-tomatoware-linux-uclibc-c++
		ln -sf ccache $BASE/native/bin/mipsel-tomatoware-linux-uclibc-cc
		ln -sf ccache $BASE/native/bin/mipsel-tomatoware-linux-uclibc-g++
		ln -sf ccache $BASE/native/bin/mipsel-tomatoware-linux-uclibc-gcc
	fi

	touch .symlinked-native
fi

######### ###################################################################
# NINJA # ###################################################################
######### ###################################################################
Status "compiling host-ninja"

cd $SRC/ninja

if [ ! -f .extracted-native ]; then
	rm -rf ninja-native ninja-${NINJA_VERSION}
	tar zxvf ninja-${NINJA_VERSION}.tar.gz
	mv ninja-${NINJA_VERSION} ninja-native
	touch .extracted-native
fi

cd ninja-native

if [ ! -f .built-native ]; then
	python ./configure.py --bootstrap
	mkdir -p $BASE/native/bin
	cp ninja $BASE/native/bin
	touch .built-native
fi

######### ###################################################################
# CMAKE # ###################################################################
######### ###################################################################
Status "compiling host-cmake"

cd $SRC/cmake

if [ ! -f .extracted-native ]; then
	rm -rf cmake-native cmake-${CMAKE_VERSION}
	tar zxvf cmake-${CMAKE_VERSION}.tar.gz
	mv cmake-${CMAKE_VERSION} cmake-native
	touch .extracted-native
fi

cd cmake-native

if [ ! -f .built-native ]; then
	./bootstrap \
	--prefix=$BASE/native \
	--parallel=`nproc` \
	--generator=Ninja \
	--system-curl \
	-- \
	-DCMAKE_BUILD_TYPE=Release
	$NINJA
	$NINJA install
	touch .built-native
fi

########## ##################################################################
# CCACHE # ##################################################################
########## ##################################################################
Status "compiling host-ccache"

cd $SRC/ccache

if [ ! -f .extracted-native ]; then
	rm -rf ccache-native ccache-${CCACHE_VERSION}
	tar xvJf ccache-${CCACHE_VERSION}.tar.xz
	mv ccache-${CCACHE_VERSION} ccache-native
	touch .extracted-native
fi

cd ccache-native

if [ ! -f .built-native ]; then
	cmake \
	-Wno-dev \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=$BASE/native \
	-DZSTD_FROM_INTERNET=ON \
	-DREDIS_STORAGE_BACKEND=OFF \
	./
	$MAKE
	make install
	touch .built-native
fi

############ ################################################################
# AUTOCONF # ################################################################
############ ################################################################
Status "compiling host-autoconf"

cd $SRC/autoconf

if [ ! -f .extracted-native ]; then
	rm -rf autoconf-native autoconf-${AUTOCONF_VERSION}
	tar xvJf autoconf-${AUTOCONF_VERSION}.tar.xz
	mv autoconf-${AUTOCONF_VERSION} autoconf-native
	touch .extracted-native
fi

cd autoconf-native

if [ ! -f .built-native ]; then
	./configure \
	--prefix=$BASE/native
	$MAKE
	$MAKE1 install
	touch .built-native
fi

############ ################################################################
# HOST GCC # ################################################################
############ ################################################################
Status "compiling host-gcc"

if [ "$BUILDHOSTGCC" == "1" ] && [ ! -f /opt/tomatoware/x86_64/bin/cc ]; then

	mkdir -p $SRC/gcc_host && cd $SRC/gcc_host

	if [ ! -f .built ]; then
		rm -rf gcc-${GCC_VERSION} gcc-build
		tar xvJf $SRC/toolchain/dl/gcc/gcc-${GCC_VERSION}.tar.xz -C $SRC/gcc_host
		mkdir gcc-build
		cd gcc-${GCC_VERSION}
		./contrib/download_prerequisites
		cd ../gcc-build

		../gcc-${GCC_VERSION}/configure \
		--prefix=/opt/tomatoware/x86_64 \
		--enable-languages=c,c++ \
		--disable-multilib

		$MAKE
		make install
		ln -s gcc /opt/tomatoware/x86_64/bin/cc
		touch .built
	fi
fi

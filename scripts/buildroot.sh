#!/bin/bash

source ./scripts/environment.sh

######## ####################################################################
# GLIB # ####################################################################
######## ####################################################################

if [ "$DESTARCH" == "mipsel" ];then
	GLIB_VERSION=2.26.1
else
	GLIB_VERSION=2.58.3
fi

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/glib2

if [ ! -f .extracted ]; then
	rm -rf glib-${GLIB_VERSION}
	if [ "$DESTARCH" == "mipsel" ];then
		tar zxvf glib-${GLIB_VERSION}.tar.gz
	else
		tar xvJf glib-${GLIB_VERSION}.tar.xz
	fi
	touch .extracted
fi

cd glib-${GLIB_VERSION}

if [ ! -f .patched ]; then
	if [ "$DESTARCH" == "mipsel" ];then
		patch < $PATCHES/glib2.mipsel/001-automake-compat.patch
		patch -p1 < $PATCHES/glib2.mipsel/002-missing-gthread-include.patch
		patch < $PATCHES/glib2.mipsel/010-move-iconv-to-libs.patch
		touch .patched
	else
		patch -p1 < $PATCHES/glib2/000-CVE-2019-12450.patch
		patch -p1 < $PATCHES/glib2/001-automake-compat.patch
		patch -p1 < $PATCHES/glib2/002-fix-gthreadedresolver.patch
		touch .patched
	fi
fi

if [ ! -f .configured ]; then
	if [ "$DESTARCH" == "mipsel" ];then
		LDFLAGS=$LDFLAGS \
		CPPFLAGS=$CPPFLAGS \
		CFLAGS=$CFLAGS \
		CXXFLAGS=$CXXFLAGS \
		$CONFIGURE \
		--with-libiconv=native  \
		--enable-static \
		glib_cv_stack_grows=no \
		glib_cv_uscore=no \
		ac_cv_func_posix_getpwuid_r=yes \
		ac_cv_func_posix_getgrgid_r=yes
		touch .configured
	else
		autoreconf -f -i
		LDFLAGS=$LDFLAGS \
		CPPFLAGS=$CPPFLAGS \
		CFLAGS="-Wno-error=missing-include-dirs -Wno-error=format-nonliteral $CFLAGS" \
		CXXFLAGS=$CXXFLAGS \
		$CONFIGURE \
		--enable-shared \
		--enable-static \
		--disable-debug \
		--disable-selinux \
		--disable-libmount \
		--disable-fam \
		--disable-man \
		--with-libiconv=native \
		--with-pcre=internal \
		glib_cv_stack_grows=no \
		glib_cv_uscore=no \
		ac_cv_path_GLIB_GENMARSHAL=`which glib-genmarshal` \
		ac_cv_func_mmap_fixed_mapped=yes \
		c_cv_func_posix_getpwuid_r=yes \
		ac_cv_func_posix_getgrgid_r=yes
		touch .configured
	fi
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

unset PKG_CONFIG_LIBDIR

############## ##############################################################
# PKG-CONFIG # ##############################################################
############## ##############################################################

PKG_CONFIG_VERSION=0.29.2

cd $SRC/pkg-config

if [ ! -f .extracted ]; then
	rm -rf pkg-config-${PKG_CONFIG_VERSION}
	tar zxvf pkg-config-${PKG_CONFIG_VERSION}.tar.gz
	touch .extracted
fi

cd pkg-config-${PKG_CONFIG_VERSION}

if [ ! -f .configured ]; then
	GLIB_CFLAGS="-I$DEST/include/glib-2.0 -I$DEST/lib/glib-2.0/include" \
	GLIB_LIBS="-lglib-2.0" \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-pc-path=$DEST/lib/pkgconfig
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# GMP # #####################################################################
####### #####################################################################

GMP_VERSION=6.2.1

cd $SRC/gmp

if [ ! -f .extracted ]; then
	rm -rf gmp-${GMP_VERSION}
	tar xvJf gmp-${GMP_VERSION}.tar.xz
	touch .extracted
fi

cd gmp-${GMP_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-cxx
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# MPFR # ####################################################################
######## ####################################################################

MPFR_VERSION=4.1.0

cd $SRC/mpfr

if [ ! -f .extracted ]; then
	rm -rf mpfr-${MPFR_VERSION}
	tar xvJf mpfr-${MPFR_VERSION}.tar.xz
	touch .extracted
fi

cd mpfr-${MPFR_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .edit_sed ]; then
	sed -i 's,'"$PREFIX"'\/lib\/libgmp.la,'"$DEST"'\/lib\/libgmp.la,g' \
	$DEST/lib/libmpfr.la
	touch .edit_sed
fi

####### #####################################################################
# MPC # #####################################################################
####### #####################################################################

MPC_VERSION=1.2.1

cd $SRC/mpc

if [ ! -f .extracted ]; then
	rm -rf mpc-${MPC_VERSION}
	tar zxvf mpc-${MPC_VERSION}.tar.gz
	touch .extracted
fi

cd mpc-${MPC_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-mpfr=$DEST \
	--with-gmp=$DEST
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

############ ################################################################
# BINUTILS # ################################################################
############ ################################################################

mkdir -p $SRC/binutils && cd $SRC/binutils

if [ ! -f .extracted ]; then
	rm -rf binutils-${BINUTILS_VERSION} build-binutils
	tar xvJf $SRC/toolchain/dl/binutils/binutils-${BINUTILS_VERSION}.tar.xz -C $SRC/binutils
	mkdir build-binutils
	touch .extracted
fi

cd build-binutils

if [ "$DESTARCH" == "mipsel" ];then
        os=mipsel-tomatoware-linux-uclibc
fi

if [ "$DESTARCH" == "arm" ];then
	os=arm-tomatoware-linux-uclibcgnueabi
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	../binutils-${BINUTILS_VERSION}/configure --prefix=$PREFIX --host=$os --target=$os \
	--with-sysroot=$PREFIX \
	--enable-gold=yes \
	--disable-werror \
	--disable-nls
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .symlinked ]; then
	for link in addr2line ar c++filt gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf size strings strip
	do
		ln -sf $link $DEST/bin/$DESTARCH-linux-$link
		ln -sf $link $DEST/bin/$DESTARCH-tomatoware-linux-uclibc$GNUEABI-$link
	done
	touch .symlinked
fi

################## ##########################################################
# BINUTILS-CROSS # ##########################################################
################## ##########################################################

if [ "$DESTARCH" == "arm" ] && [ "$BUILDCROSSTOOLS" == "1" ]; then

mkdir -p $SRC/binutils-cross && cd $SRC/binutils-cross

if [ ! -f .extracted ]; then
	rm -rf binutils-${BINUTILS_VERSION} build-binutils
	tar xvJf $SRC/toolchain/dl/binutils/binutils-${BINUTILS_VERSION}.tar.xz -C $SRC/binutils-cross
	mkdir build-binutils
	touch .extracted
fi

cd build-binutils

hostos=arm-tomatoware-linux-uclibcgnueabi
targetos=mipsel-tomatoware-linux-uclibc

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	../binutils-${BINUTILS_VERSION}/configure --prefix=$PREFIX --host=$hostos --target=$targetos \
	--with-sysroot=$PREFIX/mipsel$PREFIX \
	--enable-gold=yes \
	--disable-werror \
	--disable-nls
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .symlinked ]; then
	ln -sf $PREFIX/mipsel$PREFIX/include $DEST/mipsel-tomatoware-linux-uclibc/include

	for link in addr2line ar c++filt gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf size strings strip
	do
		ln -sf mipsel-tomatoware-linux-uclibc-$link $DEST/bin/mipsel-linux-$link
	done
	touch .symlinked
fi

fi

####### #####################################################################
# GCC # #####################################################################
####### #####################################################################

mkdir -p $SRC/gcc && cd $SRC/gcc

if [ ! -f .extracted ]; then
	rm -rf gcc-${GCC_VERSION} gcc-build
	tar xvJf $SRC/toolchain/dl/gcc/gcc-${GCC_VERSION}.tar.xz -C $SRC/gcc
	mkdir gcc-build
	touch .extracted
fi

cd gcc-${GCC_VERSION}

if [ ! -f .patched ]; then
	cp $PATCHES/gcc/gcc-10.1.0-specs-1.patch .
	cp $PATCHES/gcc/0005-add-tomatoware-certs-path.patch .
	sed -i 's,\/opt,'"$PREFIX"',g' \
		gcc-10.1.0-specs-1.patch \
		0005-add-tomatoware-certs-path.patch

	patch -p1 < gcc-10.1.0-specs-1.patch
	patch -p1 < $PATCHES/gcc/0810-arm-softfloat-libgcc.patch
	patch -p1 < $PATCHES/gcc/0004-fix-libgo-for-arm.patch
	patch -p1 < 0005-add-tomatoware-certs-path.patch
	touch .patched
fi

cd ../gcc-build

if [ "$DESTARCH" == "mipsel" ]; then
	os=mipsel-tomatoware-linux-uclibc
	gccextraconfig="--with-abi=32
			--with-arch=mips32"
	gcclangs="c,c++"
fi

if [ "$DESTARCH" == "arm" ];then
	os=arm-tomatoware-linux-uclibcgnueabi
	gccextraconfig="--with-abi=aapcs-linux
			--with-cpu=cortex-a9
			--with-mode=arm"
	gcclangs="c,c++,go"
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	../gcc-${GCC_VERSION}/configure --prefix=$PREFIX --host=$os --target=$os \
	--with-mpc-include=$DEST/include \
	--with-mpc-lib=$DEST/lib \
	--with-mpfr-include=$DEST/include \
	--with-mpfr-lib=$DEST/lib \
	--with-gmp-include=$DEST/include \
	--with-gmp-lib=$DEST/lib \
	--with-sysroot=$PREFIX \
	--with-build-sysroot=/opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/sysroot/ \
	--enable-languages=$gcclangs \
	--enable-shared \
	--enable-static \
	--enable-threads=posix \
	--enable-tls \
	--enable-__cxa_atexit \
	--enable-version-specific-runtime-libs \
	--with-float=soft \
	--with-gnu-as \
	--with-gnu-ld \
	--disable-decimal-float \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libsanitizer \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--without-cloog \
	--without-isl \
	$gccextraconfig
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .symlinked ]; then
	ln -sf gcc $DEST/bin/cc
	ln -sf gcc $DEST/bin/$DESTARCH-linux-cc
	ln -sf gcc $DEST/bin/$DESTARCH-linux-gcc
	ln -sf gcc $DEST/bin/$DESTARCH-tomatoware-linux-uclibc$GNUEABI-cc
	ln -sf g++ $DEST/bin/c++
	ln -sf g++ $DEST/bin/$DESTARCH-linux-c++
	ln -sf g++ $DEST/bin/$DESTARCH-linux-g++
	ln -sf gccgo $DEST/bin/$DESTARCH-linux-gccgo
        touch .symlinked
fi

############# ###############################################################
# GCC-CROSS # ###############################################################
############# ###############################################################

if [ "$DESTARCH" == "arm" ] && [ "$BUILDCROSSTOOLS" == "1" ]; then

mkdir -p $SRC/gcc-cross && cd $SRC/gcc-cross

if [ ! -f .extracted ]; then
	rm -rf gcc-${GCC_VERSION} gcc-build
	tar xvJf $SRC/toolchain/dl/gcc/gcc-${GCC_VERSION}.tar.xz -C $SRC/gcc-cross
	mkdir gcc-build
	touch .extracted
fi

cd gcc-${GCC_VERSION}

if [ ! -f .patched ]; then
	cp $PATCHES/gcc/gcc-10.1.0-specs-1.patch .
	sed -i 's,\/opt,'"$PREFIX"',g' gcc-10.1.0-specs-1.patch
	patch -p1 < gcc-10.1.0-specs-1.patch
	patch -p1 < $PATCHES/gcc/0810-arm-softfloat-libgcc.patch
	touch .patched
fi

cd ../gcc-build

hostos=arm-tomatoware-linux-uclibcgnueabi
targetos=mipsel-tomatoware-linux-uclibc
gccextraconfig="--with-abi=32
		--with-arch=mips32"

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	../gcc-${GCC_VERSION}/configure --prefix=$PREFIX --host=$hostos --target=$targetos \
	--with-mpc-include=$DEST/include \
	--with-mpc-lib=$DEST/lib \
	--with-mpfr-include=$DEST/include \
	--with-mpfr-lib=$DEST/lib \
	--with-gmp-include=$DEST/include \
	--with-gmp-lib=$DEST/lib \
	--with-sysroot=$PREFIX/mipsel$PREFIX \
	--with-build-sysroot=/opt/tomatoware/mipsel-soft${PREFIX////-}/mipsel-tomatoware-linux-uclibc/sysroot/ \
	--enable-languages=c,c++ \
	--enable-shared \
	--enable-static \
	--enable-threads=posix \
	--enable-tls \
	--enable-__cxa_atexit \
	--enable-version-specific-runtime-libs \
	--with-float=soft \
	--with-gnu-as \
	--with-gnu-ld \
	--disable-decimal-float \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libsanitizer \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-multilib \
	--disable-nls \
	--disable-werror \
	--without-cloog \
	--without-isl \
	$gccextraconfig
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi
if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .symlinked ]; then
	ln -sf mipsel-tomatoware-linux-uclibc-gcc $DEST/bin/mipsel-linux-cc
	ln -sf mipsel-tomatoware-linux-uclibc-gcc $DEST/bin/mipsel-linux-gcc
	ln -sf mipsel-tomatoware-linux-uclibc-g++ $DEST/bin/mipsel-linux-c++
	ln -sf mipsel-tomatoware-linux-uclibc-g++ $DEST/bin/mipsel-linux-g++

	ln -sf $PREFIX/mipsel$PREFIX/usr/lib/crt1.o  $DEST/mipsel-tomatoware-linux-uclibc/lib/crt1.o
	ln -sf $PREFIX/mipsel$PREFIX/usr/lib/crti.o  $DEST/mipsel-tomatoware-linux-uclibc/lib/crti.o
	ln -sf $PREFIX/mipsel$PREFIX/usr/lib/crtn.o  $DEST/mipsel-tomatoware-linux-uclibc/lib/crtn.o
	ln -sf $PREFIX/mipsel$PREFIX/usr/lib/Scrt1.o $DEST/mipsel-tomatoware-linux-uclibc/lib/Scrt1.o
	touch .symlinked
fi

fi

######### ###################################################################
# NINJA # ###################################################################
######### ###################################################################

cd $SRC/ninja

if [ ! -f .extracted ]; then
	rm -rf ninja-v${NINJA_VERSION}
	tar zxvf ninja-v${NINJA_VERSION}.tar.gz
	touch .extracted
fi

cd ninja-v${NINJA_VERSION}

if [ ! -f .configured ]; then
	CXX=$DESTARCH-linux-g++ \
	AR=$DESTARCH-linux-ar \
	LDFLAGS="-static $LDFLAGS" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure.py
	touch .configured
fi

if [ ! -f .built ]; then
	ninja
	touch .built
fi

if [ ! -f $DEST/bin/ninja ]; then
	cp ninja $DEST/bin/
	cp $SRC/ninja/ninja.1 $DEST/man/man1
fi

######### ###################################################################
# CMAKE # ###################################################################
######### ###################################################################

cd $SRC/cmake

if [ ! -f .extracted ]; then
	rm -rf cmake-${CMAKE_VERSION}
	tar zxvf cmake-${CMAKE_VERSION}.tar.gz
	touch .extracted
fi

cd cmake-${CMAKE_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/cmake/cmake.patch
	if [ "$DESTARCH" == "mipsel" ];then
		patch -p1 < $PATCHES/cmake/compat.patch
	fi
	touch .patched
fi

if [ ! -f .configured ]; then
	cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_INCLUDE_PATH=$DEST/include \
	-DCMAKE_LIBRARY_PATH=$DEST/lib \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	-DOPENSSL_ROOT_DIR=$DEST \
	-DOPENSSL_LIBRARIES=$DEST/lib \
	-DCURSES_INCLUDE_PATH=$DEST/include \
	-DCURSES_CURSES_LIBRARY=$DEST/lib/libcurses.so \
	./
	touch .configured
fi

if [ ! -f .edit_sed ]; then
	sed -i '/cmake_install/s/bin\/cmake/\/usr\/bin\/cmake/g' Makefile
	touch .edit_sed
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# LLVM # ####################################################################
######## ####################################################################

if [ "$BUILDLLVM" == "1" ] && [ "$DESTARCH" == "arm" ]; then

LLVM_VERSION=11.0.0

cd $SRC/llvm

if [ ! -f .extracted ]; then
	rm -rf llvm-project-${LLVM_VERSION} llvm-project-${LLVM_VERSION}_host
	tar xvJf llvm-project-${LLVM_VERSION}.tar.xz
	cp -r llvm-project-${LLVM_VERSION} llvm-project-${LLVM_VERSION}_host
	touch .extracted
fi

cd llvm-project-${LLVM_VERSION}_host

if [ ! -f .built-native ]; then

	mkdir -p build && cd build

	if [ "$BUILDHOSTGCC" == "1" ]; then
		PATH=$BASE/native/bin:/opt/tomatoware/x86_64/bin:$ORIGINALPATH \
		cmake \
		-GNinja \
		-DCMAKE_BUILD_TYPE=Release \
		-DLLVM_ENABLE_PROJECTS="clang;lldb" \
		-DCMAKE_CXX_LINK_FLAGS="-Wl,-rpath,/opt/tomatoware/x86_64/lib64 -L/opt/tomatoware/x86_64/lib64" \
		-DLLDB_ENABLE_LIBEDIT=OFF \
		../llvm/
		PATH=$BASE/native/bin:/opt/tomatoware/x86_64/bin:$ORIGINALPATH \
		ninja llvm-tblgen clang-tblgen lldb-tblgen
		touch ../.built-native
	else
		cmake \
		-GNinja \
		-DCMAKE_BUILD_TYPE=Release \
		-DLLVM_ENABLE_PROJECTS="clang;lldb" \
		-DLLDB_ENABLE_LIBEDIT=OFF \
		../llvm/
		ninja llvm-tblgen clang-tblgen lldb-tblgen
		touch ../.built-native
	fi
fi

if [ "$DESTARCH" == "mipsel" ];then
	TARGETS_TO_BUILD="Mips"
	LLVM_TARGET_ARCH="Mips"
fi

if [ "$DESTARCH" == "arm" ];then
	TARGETS_TO_BUILD="ARM;Mips"
	LLVM_TARGET_ARCH="ARM"
	MFLOAT="-mfloat-abi=soft"
	HOST_TRIPLE="armv7a-tomatoware-linux"
	TARGET_TRIPLE="armv7a-tomatoware-linux-gnueabi"
fi

C_INCLUDE_DIRS=\
lib/gcc/c++:\
lib/gcc/c++2:\
usr/include

cd $SRC/llvm/llvm-project-${LLVM_VERSION}

if [ ! -f .patched ]; then
	cp $PATCHES/llvm/dynamic-linker.patch .
	sed -i 's,mmc,'"${PREFIX#"/"}"',g' dynamic-linker.patch
	patch -p1 < dynamic-linker.patch
	patch -p1 < $PATCHES/llvm/001-llvm.patch
	patch -p1 < $PATCHES/llvm/002-ARMv7-Default-SoftFloat.patch
	patch -p1 < $PATCHES/llvm/003-CINCLUDES.patch
	touch .patched
fi

mkdir -p build

if [ ! -f .configured ]; then
	cd build
	cmake \
	-GNinja \
	-DDEFAULT_SYSROOT=$PREFIX \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CROSSCOMPILING=True \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_INCLUDE_PATH=$DEST/include \
	-DCMAKE_LIBRARY_PATH=$DEST/lib \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DCMAKE_C_FLAGS="$CPPFLAGS $CFLAGS $MFLOAT" \
	-DCMAKE_CXX_FLAGS="$CPPFLAGS $CXXFLAGS $MFLOAT" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	-DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" \
	-DC_INCLUDE_DIRS="$C_INCLUDE_DIRS" \
	-DFFI_INCLUDE_DIR=$DEST/include \
	-DFFI_LIBRARY_DIR=$DEST/lib \
	-DLLVM_ENABLE_FFI=ON \
	-DLLVM_ENABLE_LIBEDIT=ON \
	-DLLVM_BUILD_LLVM_DYLIB=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON \
	-DLLVM_ENABLE_THREADS=ON \
	-DLLVM_ENABLE_PROJECTS="clang;lld;lldb" \
	-DLLVM_HOST_TRIPLE=$HOST_TRIPLE \
	-DLLVM_TARGET_ARCH=$LLVM_TARGET_ARCH \
	-DLLVM_TARGETS_TO_BUILD=$TARGETS_TO_BUILD \
	-DLLVM_DEFAULT_TARGET_TRIPLE=$TARGET_TRIPLE \
	-DLLVM_TABLEGEN="$SRC/llvm/llvm-project-${LLVM_VERSION}_host/build/bin/llvm-tblgen" \
	-DCLANG_DEFAULT_LINKER="lld" \
	-DCLANG_TABLEGEN="$SRC/llvm/llvm-project-${LLVM_VERSION}_host/build/bin/clang-tblgen" \
	-DLLDB_TABLEGEN="$SRC/llvm/llvm-project-${LLVM_VERSION}_host/build/bin/lldb-tblgen" \
	-DLLDB_ENABLE_LUA=OFF \
	-DLLDB_ENABLE_PYTHON=OFF \
	../llvm
	touch ../.configured
fi

cd $SRC/llvm/llvm-project-${LLVM_VERSION}/build

if [ ! -f .built ]; then
	ninja
	touch .built
fi

if [ ! -f .installed ]; then
	DESTDIR=$BASE ninja install
	touch .installed
fi

if [ ! -f .postinstalled ]; then
	ln -sf llvm-ar $DEST/bin/clang-ar

	if [ "$DESTARCH" = "arm" ]; then

		ln -s arm-tomatoware-linux-uclibcgnueabi $DEST/lib/gcc/armv7a-tomatoware-linux-gnueabi

		echo '#!/bin/sh' > $DEST/bin/clang-mipsel
		echo '#!/bin/sh' > $DEST/bin/clang++-mipsel
		echo 'exec '"$PREFIX"'/bin/clang   --sysroot='"$PREFIX"'/mipsel'"$PREFIX"' --target='"$MIPSEL"' -mfloat-abi=soft -mips32 "$@"' >> $DEST/bin/clang-mipsel
		echo 'exec '"$PREFIX"'/bin/clang++ --sysroot='"$PREFIX"'/mipsel'"$PREFIX"' --target='"$MIPSEL"' -mfloat-abi=soft -mips32 "$@"' >> $DEST/bin/clang++-mipsel
		chmod +x $DEST/bin/clang-mipsel $DEST/bin/clang++-mipsel

		if [ "$BUILDCROSSTOOLS" == "1" ]; then

			echo '#!/bin/sh' > $DEST/bin/mipsel-linux-pkg-config
			echo 'export PKG_CONFIG_DIR=' >> $DEST/bin/mipsel-linux-pkg-config
			echo 'export PKG_CONFIG_LIBDIR='"$PREFIX"'/mipsel'"$PREFIX"'/lib/pkgconfig' >> $DEST/bin/mipsel-linux-pkg-config
			echo 'export PKG_CONFIG_SYSROOT_DIR='"$PREFIX"'/mipsel' >> $DEST/bin/mipsel-linux-pkg-config
			echo 'exec pkg-config "$@"' >> $DEST/bin/mipsel-linux-pkg-config
			chmod +x $DEST/bin/clang-mipsel $DEST/bin/mipsel-linux-pkg-config

			ln -sf $PREFIX/bin/ld.lld $DEST/mipsel-tomatoware-linux-uclibc/bin/ld.lld
		fi
	fi

	touch .postinstalled
fi

fi

########## ##################################################################
# GOLANG # ##################################################################
########## ##################################################################

GOLANG_VERSION=1.15.5

cd $SRC/golang

if [ ! -f .extracted ]; then
	rm -rf go go-*
	tar xvJf go${GOLANG_VERSION}.linux-amd64.tar.xz
	mv go go-native
	tar zxvf go${GOLANG_VERSION}.src.tar.gz
	touch .extracted
fi

cd go/src

if [ ! -f .patched ]; then
	cp $PATCHES/golang/golang-ssl.patch .
	sed -i 's,PREFIX,'"$PREFIX"',g' ./golang-ssl.patch
	patch -p1 < ./golang-ssl.patch
	touch .patched
fi

if [ ! -f .built ]; then

	if [ "$DESTARCH" == "mipsel" ]; then
		PATH=$SRC/golang/go-native/bin:$PATH \
		GOOS=linux \
		GOARCH=mipsle \
		GOMIPS=softfloat \
		./bootstrap.bash

		tar xvjf $SRC/golang/go-linux-mipsle-bootstrap.tbz -C $DEST/bin
		mv $DEST/bin/go-linux-mipsle-bootstrap $DEST/bin/go-bin
	fi

	if [ "$DESTARCH" == "arm" ]; then
		PATH=$SRC/golang/go-native/bin:$PATH \
		GOOS=linux \
		GOARCH=arm \
		GOARM=5 \
		./bootstrap.bash

		tar xvjf $SRC/golang/go-linux-arm-bootstrap.tbz -C $DEST/bin
		mv $DEST/bin/go-linux-arm-bootstrap $DEST/bin/go-bin
	fi
	touch .built
fi

########## ##################################################################
# CCACHE # ##################################################################
########## ##################################################################

cd $SRC/ccache

if [ ! -f .extracted ]; then
        rm -rf ccache-${CCACHE_VERSION}
        tar xvJf ccache-${CCACHE_VERSION}.tar.xz
        touch .extracted
fi

cd ccache-${CCACHE_VERSION}

if [ "$DESTARCH" == "mipsel" ]; then
	atomic="-latomic"
fi


if [ ! -f .configured ]; then
	cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_INCLUDE_PATH=$DEST/include \
	-DCMAKE_LIBRARY_PATH=$DEST/lib \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$atomic $LDFLAGS" \
	./
	touch .configured
fi

if [ ! -f .built ]; then
        $MAKE
        touch .built
fi

if [ ! -f .installed ]; then
        make install DESTDIR=$BASE
        touch .installed
fi

if [ ! -f .symlinked ]; then
	mkdir -p $DEST/bin/ccache_bin

	ln -sf ../ccache $DEST/bin/ccache_bin/c++
	ln -sf ../ccache $DEST/bin/ccache_bin/cc
	ln -sf ../ccache $DEST/bin/ccache_bin/g++
	ln -sf ../ccache $DEST/bin/ccache_bin/gcc
	ln -sf ../ccache $DEST/bin/ccache_bin/$DESTARCH-linux-c++
	ln -sf ../ccache $DEST/bin/ccache_bin/$DESTARCH-linux-cc
	ln -sf ../ccache $DEST/bin/ccache_bin/$DESTARCH-linux-g++
	ln -sf ../ccache $DEST/bin/ccache_bin/$DESTARCH-linux-gcc
	ln -sf ../ccache $DEST/bin/ccache_bin/$DESTARCH-tomatoware-linux-uclibc$GNUEABI-c++
	ln -sf ../ccache $DEST/bin/ccache_bin/$DESTARCH-tomatoware-linux-uclibc$GNUEABI-cc
	ln -sf ../ccache $DEST/bin/ccache_bin/$DESTARCH-tomatoware-linux-uclibc$GNUEABI-g++
	ln -sf ../ccache $DEST/bin/ccache_bin/$DESTARCH-tomatoware-linux-uclibc$GNUEABI-gcc
	ln -sf ../ccache $DEST/bin/ccache_bin/clang
	ln -sf ../ccache $DEST/bin/ccache_bin/clang++

	if [ "$DESTARCH" == "arm" ] && [ "$BUILDCROSSTOOLS" == "1" ]; then

		ln -sf ../ccache $DEST/bin/ccache_bin/mipsel-linux-c++
		ln -sf ../ccache $DEST/bin/ccache_bin/mipsel-linux-cc
		ln -sf ../ccache $DEST/bin/ccache_bin/mipsel-linux-g++
		ln -sf ../ccache $DEST/bin/ccache_bin/mipsel-linux-gcc
		ln -sf ../ccache $DEST/bin/ccache_bin/mipsel-tomatoware-linux-uclibc-c++
		ln -sf ../ccache $DEST/bin/ccache_bin/mipsel-tomatoware-linux-uclibc-cc
		ln -sf ../ccache $DEST/bin/ccache_bin/mipsel-tomatoware-linux-uclibc-g++
		ln -sf ../ccache $DEST/bin/ccache_bin/mipsel-tomatoware-linux-uclibc-gcc
		ln -sf ../ccache $DEST/bin/ccache_bin/clang-mipsel
		ln -sf ../ccache $DEST/bin/ccache_bin/clang++-mipsel
	fi
	touch .symlinked
fi

############ ################################################################
# AUTOCONF # ################################################################
############ ################################################################

AUTOCONF_VERSION=2.69

cd $SRC/autoconf

if [ ! -f .extracted ]; then
	rm -rf autoconf-${AUTOCONF_VERSION}
	tar xvJf autoconf-${AUTOCONF_VERSION}.tar.xz
	touch .extracted
fi

cd autoconf-${AUTOCONF_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

############ ################################################################
# AUTOMAKE # ################################################################
############ ################################################################

AUTOMAKE_VERSION=1.16.3

cd $SRC/automake

if [ ! -f .extracted ]; then
	rm -rf automake-${AUTOMAKE_VERSION}
	tar xvJf automake-${AUTOMAKE_VERSION}.tar.xz
	touch .extracted
fi

cd automake-${AUTOMAKE_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# BISON # ###################################################################
######### ###################################################################

BISON_VERSION=3.7.4

cd $SRC/bison

if [ ! -f .extracted ]; then
	rm -rf bison-${BISON_VERSION}
	tar xvJf bison-${BISON_VERSION}.tar.xz
	touch .extracted
fi

cd bison-${BISON_VERSION}

if [ ! -f .patched ]; then
	cp -v Makefile.in{,.orig}
	sed '/bison.help:/s/^/# /' Makefile.in.orig > Makefile.in
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# CHECK # ###################################################################
######### ###################################################################

CHECK_VERSION=0.10.0

cd $SRC/check

if [ ! -f .extracted ]; then
	rm -rf check-${CHECK_VERSION}
	tar zxvf check-${CHECK_VERSION}.tar.gz
	touch .extracted
fi

cd check-${CHECK_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

############# ###############################################################
# COREUTILS # ###############################################################
############# ###############################################################

COREUTILS_VERSION=8.32

cd $SRC/coreutils

if [ ! -f .extracted ]; then
	rm -rf coreutils-${COREUTILS_VERSION}
	tar xvJf coreutils-${COREUTILS_VERSION}.tar.xz
	touch .extracted
fi

cd coreutils-${COREUTILS_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/coreutils/0001-ls-restore-8.31-behavior-on-removed-directories.patch
	autoreconf
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-no-install-program=uptime \
	--enable-install-program=hostname \
	fu_cv_sys_stat_statfs2_bsize=yes \
	gl_cv_func_working_mkstemp=yes
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

############# ###############################################################
# DIFFUTILS # ###############################################################
############# ###############################################################

DIFFUTILS_VERSION=3.7

cd $SRC/diffutils

if [ ! -f .extracted ]; then
	rm -rf diffutils-${DIFFUTILS_VERSION}
	tar xvJf diffutils-${DIFFUTILS_VERSION}.tar.xz
	touch .extracted
fi

cd diffutils-${DIFFUTILS_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

############# ###############################################################
# FINDUTILS # ###############################################################
############# ###############################################################

FINDUTILS_VERSION=4.7.0

cd $SRC/findutils

if [ ! -f .extracted ]; then
	rm -rf findutils-${FINDUTILS_VERSION}
	tar xvJf findutils-${FINDUTILS_VERSION}.tar.xz
	touch .extracted
fi

cd findutils-${FINDUTILS_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	gl_cv_func_wcwidth_works=yes
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# GAWK # ####################################################################
######## ####################################################################

GAWK_VERSION=5.1.0

cd $SRC/gawk

if [ ! -f .extracted ]; then
	rm -rf gawk-${GAWK_VERSION}
	tar xvJf gawk-${GAWK_VERSION}.tar.xz
	touch .extracted
fi

cd gawk-${GAWK_VERSION}

if [ ! -f .edit_sed ]; then
	cp -v extension/Makefile.in{,.orig}
	sed -e 's/check-recursive all-recursive: check-for-shared-lib-support/check-recursive all-recursive:/' extension/Makefile.in.orig > extension/Makefile.in
	touch .edit_sed
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# LIBTOOL # #################################################################
########### #################################################################

LIBTOOL_VERSION=2.4.6

cd $SRC/libtool

if [ ! -f .extracted ]; then
	rm -rf libtool-${LIBTOOL_VERSION}
	tar xvJf libtool-${LIBTOOL_VERSION}.tar.xz
	touch .extracted
fi

cd libtool-${LIBTOOL_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

############ ################################################################
# SLIBTOOL # ################################################################
############ ################################################################

SLIBTOOL_VERSION=0.5.28

cd $SRC/slibtool

if [ ! -f .extracted ]; then
        rm -rf slibtool-${SLIBTOOL_VERSION}
        tar xvJf slibtool-${SLIBTOOL_VERSION}.tar.xz
        touch .extracted
fi

cd slibtool-${SLIBTOOL_VERSION}

if [ ! -f .configured ]; then
        LDFLAGS=$LDFLAGS \
        CPPFLAGS=$CPPFLAGS \
        CFLAGS=$CFLAGS \
        CXXFLAGS=$CXXFLAGS \
        $CONFIGURE
        touch .configured
fi

if [ ! -f .built ]; then
        $MAKE
        touch .built
fi

if [ ! -f .installed ]; then
        make install DESTDIR=$BASE
        touch .installed
fi

###### ######################################################################
# M4 # ######################################################################
###### ######################################################################

M4_VERSION=1.4.18

cd $SRC/m4

if [ ! -f .extracted ]; then
	rm -rf m4-${M4_VERSION}
	tar xvJf m4-${M4_VERSION}.tar.xz
	touch .extracted
fi

cd m4-${M4_VERSION}

if [ ! -f .patched ]; then
        patch -p1 < $PATCHES/m4/gnulib_fix_posixspawn.patch
        touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# MAKE # ####################################################################
######## ####################################################################

MAKE_VERSION=4.3

cd $SRC/make

if [ ! -f .extracted ]; then
	rm -rf make-${MAKE_VERSION}
	tar zxvf make-${MAKE_VERSION}.tar.gz
	touch .extracted
fi

cd make-${MAKE_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	gl_cv_header_working_fcntl_h=yes \
	ac_cv_func_gettimeofday=yes \
	ac_cv_func_fork_works=yes \
	make_cv_synchronous_posix_spawn=no
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

############## ##############################################################
# UTIL-LINUX # ##############################################################
############## ##############################################################

if [ "$DESTARCH" == "mipsel" ];then
	UTIL_LINUX_VERSION=2.34
else
	UTIL_LINUX_VERSION=2.36
fi

cd $SRC/util-linux

if [ ! -f .extracted ]; then
	rm -rf util-linux-${UTIL_LINUX_VERSION}
	tar xvJf util-linux-${UTIL_LINUX_VERSION}.tar.xz
	touch .extracted
fi

cd util-linux-${UTIL_LINUX_VERSION}

if [ ! -f .patched ] && [ "$DESTARCH" == "mipsel" ];then
	sed -i 's,epoll_create1,epoll_create,g' ./libmount/src/monitor.c
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-mount \
	--disable-chfn-chsh-password \
	--without-python \
	--disable-nls \
	--disable-wall \
	--disable-su \
	--disable-rfkill
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# PATCH # ###################################################################
######### ###################################################################

PATCH_VERSION=2.7.6

cd $SRC/patch

if [ ! -f .extracted ]; then
	rm -rf  patch-${PATCH_VERSION}
	tar xvJf patch-${PATCH_VERSION}.tar.xz
	touch .extracted
fi

cd patch-${PATCH_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# WGET # ####################################################################
######## ####################################################################

WGET_VERSION=1.20.3

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/wget

if [ ! -f .extracted ]; then
	rm -rf wget-${WGET_VERSION}
	tar zxvf wget-${WGET_VERSION}.tar.gz
	touch .extracted
fi

cd wget-${WGET_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-ssl=openssl
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

unset PKG_CONFIG_LIBDIR

######## ####################################################################
# GREP # ####################################################################
######## ####################################################################

GREP_VERSION=3.6

cd $SRC/grep

if [ ! -f .extracted ]; then
	rm -rf grep-${GREP_VERSION}
	tar xvJf grep-${GREP_VERSION}.tar.xz
	touch .extracted
fi
 
cd grep-${GREP_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# TAR # #####################################################################
####### #####################################################################

TAR_VERSION=1.32

cd $SRC/tar

if [ ! -f .extracted ]; then
	rm -rf tar-${TAR_VERSION}
	tar xvJf tar-${TAR_VERSION}.tar.xz
	touch .extracted
fi

cd tar-${TAR_VERSION}

if [ "$DESTARCH" == "mipsel" ];then
	tarextraconfig="gl_cv_func_working_utimes=yes
			gl_cv_func_futimens_works=no
			gl_cv_func_utimensat_works=no"
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	$tarextraconfig
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# SED # #####################################################################
####### #####################################################################

SED_VERSION=4.8

cd $SRC/sed

if [ ! -f .extracted ]; then
        rm -rf sed-${SED_VERSION}
        tar xvJf sed-${SED_VERSION}.tar.xz
        touch .extracted
fi

cd sed-${SED_VERSION}

if [ ! -f .configured ]; then
        LDFLAGS=$LDFLAGS \
        CPPFLAGS=$CPPFLAGS \
        CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
        $CONFIGURE
        touch .configured
fi

if [ ! -f .built ]; then
        $MAKE
        touch .built
fi

if [ ! -f .installed ]; then
        make install DESTDIR=$BASE
        touch .installed
fi

########### #################################################################
# TEXINFO # #################################################################
########### #################################################################

TEXINFO_VERSION=6.7

cd $SRC/texinfo

if [ ! -f .extracted ]; then
        rm -rf texinfo-${TEXINFO_VERSION}
        tar xvJf texinfo-${TEXINFO_VERSION}.tar.xz
        touch .extracted
fi

cd texinfo-${TEXINFO_VERSION}

if [ ! -f .configured ]; then
        LDFLAGS=$LDFLAGS \
        CPPFLAGS=$CPPFLAGS \
        CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
        $CONFIGURE
        touch .configured
fi

if [ ! -f .built ]; then
        $MAKE
        touch .built
fi

if [ ! -f .installed ]; then
        make install DESTDIR=$BASE
        touch .installed
fi

######## ####################################################################
# CPIO # ####################################################################
######## ####################################################################

CPIO_VERSION=2.13

cd $SRC/cpio

if [ ! -f .extracted ]; then
	rm -rf cpio-${CPIO_VERSION}
	tar xvjf cpio-${CPIO_VERSION}.tar.bz2
	touch .extracted
fi

cd cpio-${CPIO_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS -fcommon" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# FILE # ####################################################################
######## ####################################################################

FILE_VERSION=5.39

cd $SRC/file

if [ ! -f .extracted ]; then
	rm -rf file-${FILE_VERSION} file-${FILE_VERSION}-native
	tar zxvf file-${FILE_VERSION}.tar.gz
	cp -r file-${FILE_VERSION} file-${FILE_VERSION}-native
	touch .extracted
fi

cd file-${FILE_VERSION}-native

if [ ! -f .built-native ]; then
	autoreconf -f -i
	./configure \
	--prefix=$SRC/file/file-${FILE_VERSION}-native
	$MAKE
	make install
	touch .built-native
fi

cd ../file-${FILE_VERSION}

if [ ! -f .configured ]; then
	autoreconf -f -i
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-static
	touch .configured
fi

if [ ! -f .built ]; then
	PATH=$SRC/file/file-${FILE_VERSION}-native/bin:$PATH \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# DISTCC # ##################################################################
########## ##################################################################

DISTCC_VERSION=3.3.3

cd $SRC/distcc

if [ ! -f .extracted ]; then
	rm -rf distcc-${DISTCC_VERSION}
	tar zxvf distcc-${DISTCC_VERSION}.tar.gz
	touch .extracted
fi

cd distcc-${DISTCC_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS -fcommon" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-libiberty \
	--disable-pump-mode \
	--disable-Werror
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# UPX # #####################################################################
####### #####################################################################

UCL_VERSION=1.03
UPX_VERSION=3.94

export UPX_UCLDIR=$SRC/upx/ucl-${UCL_VERSION}

cd $SRC/upx

if [ ! -f .extracted ]; then
	rm -rf ucl-${UCL_VERSION} upx-${UPX_VERSION}-src upx
	tar zxvf ucl-${UCL_VERSION}.tar.gz
	tar xvJf upx-${UPX_VERSION}-src.tar.xz
	mv upx-${UPX_VERSION}-src upx
	touch .extracted
fi

cd ucl-${UCL_VERSION}

if [ ! -f .built_ucl ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS="-std=c90 $CFLAGS" \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	$MAKE
	touch .built_ucl
fi

cd ../upx

if [ ! -f .built ]; then
	LDFLAGS="-static $LDFLAGS" \
	CPPFLAGS=$CPPFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE \
	CXX=$DESTARCH-linux-g++ \
	all \
	CXXFLAGS_WERROR= \
	CHECK_WHITESPACE=/bin/true
	touch .built
fi

if [ ! -f .installed ]; then
	cp ./src/upx.out $DEST/bin/upx
	cp ./doc/upx.1 $DEST/man/man1
	touch .installed
fi

unset UPX_UCLDIR

####### #####################################################################
# GDB # #####################################################################
####### #####################################################################

GDB_VERSION=7.12.1

cd $SRC/gdb

if [ ! -f .extracted ]; then
	rm -rf gdb-${GDB_VERSION}
	tar xvJf gdb-${GDB_VERSION}.tar.xz
	touch .extracted
fi

cd gdb-${GDB_VERSION}

if [ ! -f .patched ]; then
        patch -p1 < $PATCHES/gdb/0002-ppc-ptrace-Define-pt_regs-uapi_pt_regs-on-GLIBC-syst.patch
        touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS="-zmuldefs $LDFLAGS" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-build-with-cxx \
	ac_cv_type_uintptr_t=yes \
	gt_cv_func_gettext_libintl=yes \
	ac_cv_func_dcgettext=yes \
	gdb_cv_func_sigsetjmp=yes \
	bash_cv_func_strcoll_broken=no \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_func_sigsetjmp=present \
	bash_cv_have_mbstate_t=yes \
	gdb_cv_func_sigsetjmp=yes \
	gl_cv_func_working_strerror=yes \
	gl_cv_func_strerror_0_works=yes
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE \
	gl_cv_func_working_strerror=yes \
	gl_cv_func_strerror_0_works=yes
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# LESS # ####################################################################
######## ####################################################################

LESS_VERSION=563

cd $SRC/less

if [ ! -f .extracted ]; then
	rm -rf less-${LESS_VERSION}
	tar zxvf less-${LESS_VERSION}.tar.gz
	touch .extracted
fi

cd less-${LESS_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .symlinked ]; then
	ln -sf less $DEST/bin/pager
	touch .symlinked
fi

########## ##################################################################
# MANDOC # ##################################################################
########## ##################################################################

MANDOC_VERSION=1.14.5

cd $SRC/mandoc

if [ ! -f .extracted ]; then
	rm -rf mandoc-${MANDOC_VERSION}
	tar zxvf mandoc-${MANDOC_VERSION}.tar.gz
	cp $SRC/mandoc/config.h mandoc-${MANDOC_VERSION}
	cp $SRC/mandoc/Makefile.local mandoc-${MANDOC_VERSION}
	sed -i 's,mmc,'"${PREFIX#"/"}"',g' $SRC/mandoc/config.h
	touch .extracted
fi

cd mandoc-${MANDOC_VERSION}

if [ ! -f .built ]; then
	DESTARCH=$DESTARCH
	_PREFIX=$PREFIX \
	_LDFLAGS=$LDFLAGS \
	_CPPFLAGS="$CPPFLAGS -fcommon" \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	DESTARCH=$DESTARCH
	_PREFIX=$PREFIX \
	_LDFLAGS=$LDFLAGS \
	_CPPFLAGS=$CPPFLAGS \
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# DPKG # ####################################################################
######## ####################################################################

DPKG_VERSION=1.20.5

cd $SRC/dpkg

if [ ! -f .extracted ]; then
	rm -rf dpkg-${DPKG_VERSION}
	tar xvJf dpkg-${DPKG_VERSION}.tar.xz
	touch .extracted
fi

cd dpkg-${DPKG_VERSION}

if [ ! -f .configured ]; then
	PATH=$SRC/perl/native/bin:$PATH
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-sysroot=$PREFIX \
	--without-libselinux \
	PERL_LIBDIR=$PREFIX/lib/perl5/${PERL_VERSION}
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch $DEST/var/lib/dpkg/status
	touch .installed
fi

if [ ! -f .edit_sed ]; then
	grep -Irl $SRC\/perl\/native $DEST | xargs sed -i -e '1,1s,'"$SRC"'/perl/native,'"$PREFIX"',g'
	touch .edit_sed
fi

if [ ! -f .ldconfig ]; then
	touch $DEST/bin/ldconfig
	chmod +x $DEST/bin/ldconfig
	touch .ldconfig
fi

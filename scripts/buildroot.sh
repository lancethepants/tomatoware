#!/bin/bash

source ./scripts/environment.sh

######### ###################################################################
# Meson # ###################################################################
######### ###################################################################
Status "meson"

MESON_VERSION=0.62.1

cd $SRC/meson

if [ ! -f .extracted ]; then
	rm -rf meson meson-${MESON_VERSION}
	tar zxvf meson-${MESON_VERSION}.tar.gz
	mv meson-${MESON_VERSION} meson
	touch .extracted
fi

######## ####################################################################
# GLIB # ####################################################################
######## ####################################################################
Status "glib"

if [ "$DESTARCH" == "mipsel" ];then
	GLIB_VERSION=2.26.1
else
	GLIB_VERSION=2.72.1
fi

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/glib2

if [ ! -f .extracted ]; then
	rm -rf glib glib-${GLIB_VERSION}
	if [ "$DESTARCH" == "mipsel" ];then
		tar zxvf glib-${GLIB_VERSION}.tar.gz
	else
		tar xvJf glib-${GLIB_VERSION}.tar.xz
	fi
	mv glib-${GLIB_VERSION} glib
	touch .extracted
fi

cd glib

if [ ! -f .patched ]; then
	if [ "$DESTARCH" == "mipsel" ];then
		patch < $PATCHES/glib2.mipsel/001-automake-compat.patch
		patch -p1 < $PATCHES/glib2.mipsel/002-missing-gthread-include.patch
		patch < $PATCHES/glib2.mipsel/010-move-iconv-to-libs.patch
		touch .patched
	else
		patch -p1 < $PATCHES/glib2/0001-fix-compile-time-atomic-detection.patch
		patch -p1 < $PATCHES/glib2/0003-Add-Wno-format-nonliteral-to-compiler-arguments.patch
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
		PATH=$SRC/perl/native/bin:$PATH \
		$SRC/meson/meson/meson.py \
		build \
		--cross-file $SRC/meson/arm-cross.txt \
		--prefix /mmc \
		-Dbuildtype='release' \
		-Ddefault_library='both' \
		-Dstrip='true' \
		-Dselinux='disabled' \
		-Dlibmount='disabled' \
		-Dfam='false' \
		-Dman='false' \
		-Dc_args="-Wno-error=missing-include-dirs $CPPFLAGS $CFLAGS" \
		-Dcpp_args="-Wno-error=missing-include-dirs $CPPFLAGS $CXXFLAGS" \
		-Dc_link_args="$LDFLAGS" \
		-Dcpp_link_args="$LDFLAGS"
		touch .configured
	fi
fi

if [ "$DESTARCH" == "mipsel" ] && [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ "$DESTARCH" == "arm" ] && [ ! -f .built ]; then
	$SRC/meson/meson/meson.py \
	compile \
	-C build
	touch .built
fi

if [ "$DESTARCH" == "mipsel" ] && [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ "$DESTARCH" == "arm" ] && [ ! -f .installed ]; then
	DESTDIR=$BASE \
	$SRC/meson/meson/meson.py \
	install \
	-C build
	touch .installed
fi

unset PKG_CONFIG_LIBDIR

############## ##############################################################
# PKG-CONFIG # ##############################################################
############## ##############################################################
Status "pkg-config"

PKG_CONFIG_VERSION=0.29.2

cd $SRC/pkg-config

if [ ! -f .extracted ]; then
	rm -rf pkg-config pkg-config-${PKG_CONFIG_VERSION}
	tar zxvf pkg-config-${PKG_CONFIG_VERSION}.tar.gz
	mv pkg-config-${PKG_CONFIG_VERSION} pkg-config
	touch .extracted
fi

cd pkg-config

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
Status "gmp"

GMP_VERSION=6.2.1

cd $SRC/gmp

if [ ! -f .extracted ]; then
	rm -rf gmp gmp-${GMP_VERSION}
	tar xvJf gmp-${GMP_VERSION}.tar.xz
	mv gmp-${GMP_VERSION} gmp
	touch .extracted
fi

cd gmp

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
Status "mpfr"

MPFR_VERSION=4.1.0

cd $SRC/mpfr

if [ ! -f .extracted ]; then
	rm -rf mpfr mpfr-${MPFR_VERSION}
	tar xvJf mpfr-${MPFR_VERSION}.tar.xz
	mv mpfr-${MPFR_VERSION} mpfr
	touch .extracted
fi

cd mpfr

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
Status "mpc"

MPC_VERSION=1.2.1

cd $SRC/mpc

if [ ! -f .extracted ]; then
	rm -rf mpc mpc-${MPC_VERSION}
	tar zxvf mpc-${MPC_VERSION}.tar.gz
	mv mpc-${MPC_VERSION} mpc
	touch .extracted
fi

cd mpc

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
Status "binutils"

mkdir -p $SRC/binutils && cd $SRC/binutils

if [ ! -f .extracted ]; then
	rm -rf binutils binutils-${BINUTILS_VERSION} build-binutils
	tar xvJf $SRC/toolchain/dl/binutils/binutils-${BINUTILS_VERSION}.tar.xz -C $SRC/binutils
	mv binutils-${BINUTILS_VERSION} binutils
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
	../binutils/configure --prefix=$PREFIX --host=$os --target=$os \
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
Status "binutils-cross"

if [ "$DESTARCH" == "arm" ] && [ "$BUILDCROSSTOOLS" == "1" ]; then

mkdir -p $SRC/binutils-cross && cd $SRC/binutils-cross

if [ ! -f .extracted ]; then
	rm -rf binutils binutils-${BINUTILS_VERSION} build-binutils
	tar xvJf $SRC/toolchain/dl/binutils/binutils-${BINUTILS_VERSION}.tar.xz -C $SRC/binutils-cross
	mv binutils-${BINUTILS_VERSION} binutils
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
	../binutils/configure --prefix=$PREFIX --host=$hostos --target=$targetos \
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
Status "gcc"

mkdir -p $SRC/gcc && cd $SRC/gcc

if [ ! -f .extracted ]; then
	rm -rf gcc gcc-${GCC_VERSION} gcc-build
	tar xvJf $SRC/toolchain/dl/gcc/gcc-${GCC_VERSION}.tar.xz -C $SRC/gcc
	mv gcc-${GCC_VERSION} gcc
	mkdir gcc-build
	touch .extracted
fi

cd gcc

if [ ! -f .patched ]; then
	cp $PATCHES/gcc/gcc-12.1.0-specs-1.patch .
	cp $PATCHES/gcc/0003-add-tomatoware-certs-path.patch .
	sed -i 's,\/opt,'"$PREFIX"',g' \
		gcc-12.1.0-specs-1.patch \
		0003-add-tomatoware-certs-path.patch

	patch -p1 < $PATCHES/gcc/0001-fix-libgo-mips-syscall.patch
	if [ "$DESTARCH" == "mipsel" ];then
		patch -p1 < $PATCHES/gcc/0002-go-runtime-mips-epoll-fix.patch
	fi
	patch -p1 < 0003-add-tomatoware-certs-path.patch
	patch -p1 < gcc-12.1.0-specs-1.patch
	touch .patched
fi

cd ../gcc-build

if [ "$DESTARCH" == "mipsel" ]; then
	os=mipsel-tomatoware-linux-uclibc
	gccextraconfig="--with-abi=32
			--with-arch=mips32"
	gcclangs="c,c++,go"
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
	../gcc/configure --prefix=$PREFIX --host=$os --target=$os \
	--with-mpc-include=$DEST/include \
	--with-mpc-lib=$DEST/lib \
	--with-mpfr-include=$DEST/include \
	--with-mpfr-lib=$DEST/lib \
	--with-gmp-include=$DEST/include \
	--with-gmp-lib=$DEST/lib \
	--with-zstd-lib=$DEST/lib \
	--with-zstd-include=$DEST/include \
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
Status "gcc-cross"

if [ "$DESTARCH" == "arm" ] && [ "$BUILDCROSSTOOLS" == "1" ]; then

mkdir -p $SRC/gcc-cross && cd $SRC/gcc-cross

if [ ! -f .extracted ]; then
	rm -rf gcc gcc-${GCC_VERSION} gcc-build
	tar xvJf $SRC/toolchain/dl/gcc/gcc-${GCC_VERSION}.tar.xz -C $SRC/gcc-cross
	mv gcc-${GCC_VERSION} gcc
	mkdir gcc-build
	touch .extracted
fi

cd gcc

if [ ! -f .patched ]; then
	cp $PATCHES/gcc/gcc-12.1.0-specs-1.patch .
	cp $PATCHES/gcc/0003-add-tomatoware-certs-path.patch .
	sed -i 's,\/opt,'"$PREFIX"',g' \
		gcc-12.1.0-specs-1.patch \
		0003-add-tomatoware-certs-path.patch

	patch -p1 < $PATCHES/gcc/0001-fix-libgo-mips-syscall.patch
	patch -p1 < 0003-add-tomatoware-certs-path.patch
	patch -p1 < gcc-12.1.0-specs-1.patch
	patch -p1 < $PATCHES/gcc/fix-canadian-cross-build.patch
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
	../gcc/configure --prefix=$PREFIX --host=$hostos --target=$targetos \
	--with-mpc-include=$DEST/include \
	--with-mpc-lib=$DEST/lib \
	--with-mpfr-include=$DEST/include \
	--with-mpfr-lib=$DEST/lib \
	--with-gmp-include=$DEST/include \
	--with-gmp-lib=$DEST/lib \
	--with-zstd-lib=$DEST/lib \
	--with-zstd-include=$DEST/include \
	--with-sysroot=$PREFIX/mipsel$PREFIX \
	--with-build-sysroot=/opt/tomatoware/mipsel-soft${PREFIX////-}/mipsel-tomatoware-linux-uclibc/sysroot/ \
	--enable-languages=c,c++,go \
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
	ln -sf mipsel-tomatoware-linux-uclibc-gccgo $DEST/bin/mipsel-linux-gccgo

	ln -sf $PREFIX/mipsel$PREFIX/usr/lib/crt1.o  $DEST/mipsel-tomatoware-linux-uclibc/lib/crt1.o
	ln -sf $PREFIX/mipsel$PREFIX/usr/lib/crti.o  $DEST/mipsel-tomatoware-linux-uclibc/lib/crti.o
	ln -sf $PREFIX/mipsel$PREFIX/usr/lib/crtn.o  $DEST/mipsel-tomatoware-linux-uclibc/lib/crtn.o
	ln -sf $PREFIX/mipsel$PREFIX/usr/lib/Scrt1.o $DEST/mipsel-tomatoware-linux-uclibc/lib/Scrt1.o
	touch .symlinked
fi

if [ ! -f .pkgconfig ]; then

	echo '#!/bin/sh' > $DEST/bin/mipsel-linux-pkg-config
	echo 'export PKG_CONFIG_DIR=' >> $DEST/bin/mipsel-linux-pkg-config
	echo 'export PKG_CONFIG_LIBDIR='"$PREFIX"'/mipsel'"$PREFIX"'/lib/pkgconfig' >> $DEST/bin/mipsel-linux-pkg-config
	echo 'export PKG_CONFIG_SYSROOT_DIR='"$PREFIX"'/mipsel' >> $DEST/bin/mipsel-linux-pkg-config
	echo 'exec pkg-config "$@"' >> $DEST/bin/mipsel-linux-pkg-config
	chmod +x $DEST/bin/mipsel-linux-pkg-config
	touch .pkgconfig
fi

fi

######### ###################################################################
# NINJA # ###################################################################
######### ###################################################################
Status "ninja"

cd $SRC/ninja

if [ ! -f .extracted ]; then
	rm -rf ninja ninja-${NINJA_VERSION}
	tar zxvf ninja-${NINJA_VERSION}.tar.gz
	mv ninja-${NINJA_VERSION} ninja
	touch .extracted
fi

cd ninja

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
Status "cmake"

cd $SRC/cmake

if [ ! -f .extracted ]; then
	rm -rf cmake cmake-${CMAKE_VERSION}
	tar zxvf cmake-${CMAKE_VERSION}.tar.gz
	mv cmake-${CMAKE_VERSION} cmake
	touch .extracted
fi

cd cmake

if [ ! -f .patched ]; then
	if [ "$DESTARCH" == "mipsel" ];then
		patch -p1 < $PATCHES/cmake/compat.patch
	fi
	touch .patched
fi

if [ ! -f .configured ]; then
	cmake \
	-GNinja \
	-DCMAKE_SYSTEM_NAME="Linux" \
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
	-DBUILD_TESTING=OFF \
	-DHAVE_POLL_FINE=1 \
	./
	touch .configured
fi

if [ ! -f .built ]; then
	ninja
	touch .built
fi

if [ ! -f .installed ]; then
	DESTDIR=$BASE ninja install
	touch .installed
fi

######## ####################################################################
# LLVM # ####################################################################
######## ####################################################################
Status "llvm"

LLVM_VERSION=14.0.3

if [ "$BUILDLLVM" == "1" ] && [ "$DESTARCH" == "arm" ]; then

cd $SRC/llvm

if [ ! -f .extracted ]; then
	rm -rf llvm-project llvm-project-host llvm-project-${LLVM_VERSION}.src
	tar xvJf llvm-project-${LLVM_VERSION}.src.tar.xz
	mv llvm-project-${LLVM_VERSION}.src llvm-project
	tar xvJf llvm-project-${LLVM_VERSION}.src.tar.xz
	mv llvm-project-${LLVM_VERSION}.src llvm-project-host
	touch .extracted
fi

cd llvm-project-host

if [ ! -f .built-native ]; then

	mkdir -p build && cd build

	if [ "$BUILDHOSTGCC" == "1" ]; then
		PATH=$BASE/native/bin:/opt/tomatoware/x86_64/bin:$ORIGINALPATH \
		cmake \
		-GNinja \
		-Wno-dev \
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
		-Wno-dev \
		-DCMAKE_BUILD_TYPE=Release \
		-DLLVM_ENABLE_PROJECTS="clang;lldb" \
		-DLLDB_ENABLE_LIBEDIT=OFF \
		../llvm/
		ninja llvm-tblgen clang-tblgen lldb-tblgen
		touch ../.built-native
	fi
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

cd $SRC/llvm/llvm-project

if [ ! -f .patched ]; then
	cp $PATCHES/llvm/dynamic-linker.patch .
	sed -i 's,mmc,'"${PREFIX#"/"}"',g' dynamic-linker.patch
	patch -p1 < dynamic-linker.patch
	patch -p1 < $PATCHES/llvm/001-llvm.patch
	patch -p1 < $PATCHES/llvm/002-ARMv7-Default-SoftFloat.patch
	patch -p1 < $PATCHES/llvm/003-CINCLUDES.patch
	patch -p1 < $PATCHES/llvm/004-getloadavg.patch
	touch .patched
fi

mkdir -p build

if [ ! -f .configured ]; then
	cd build
	cmake \
	-GNinja \
	-Wno-dev \
	-DDEFAULT_SYSROOT=$PREFIX \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_SYSTEM_NAME="Linux" \
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
	-DLLVM_TABLEGEN="$SRC/llvm/llvm-project-host/build/bin/llvm-tblgen" \
	-DCLANG_DEFAULT_LINKER="lld" \
	-DCLANG_TABLEGEN="$SRC/llvm/llvm-project-host/build/bin/clang-tblgen" \
	-DLLDB_TABLEGEN="$SRC/llvm/llvm-project-host/build/bin/lldb-tblgen" \
	-DLLDB_ENABLE_LUA=OFF \
	-DLLDB_ENABLE_PYTHON=OFF \
	../llvm
	touch ../.configured
fi

cd $SRC/llvm/llvm-project/build

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
	ln -sf arm-tomatoware-linux-uclibcgnueabi $DEST/lib/gcc/armv7a-tomatoware-linux-gnueabi

	if [ "$BUILDCROSSTOOLS" == "1" ]; then

		ln -sf $PREFIX/bin/ld.lld $DEST/mipsel-tomatoware-linux-uclibc/bin/ld.lld

		echo '#!/bin/sh' > $DEST/bin/clang-mipsel
		echo '#!/bin/sh' > $DEST/bin/clang++-mipsel
		echo 'exec '"$PREFIX"'/bin/clang   --sysroot='"$PREFIX"'/mipsel'"$PREFIX"' --target='"$MIPSEL"' -mfloat-abi=soft -mips32 "$@"' >> $DEST/bin/clang-mipsel
		echo 'exec '"$PREFIX"'/bin/clang++ --sysroot='"$PREFIX"'/mipsel'"$PREFIX"' --target='"$MIPSEL"' -mfloat-abi=soft -mips32 "$@"' >> $DEST/bin/clang++-mipsel
		chmod +x $DEST/bin/clang-mipsel $DEST/bin/clang++-mipsel
	fi
	touch .postinstalled
fi

fi

########## ##################################################################
# GOLANG # ##################################################################
########## ##################################################################
Status "golang"

GOLANG_VERSION=1.18.2

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
Status "ccache"

cd $SRC/ccache

if [ ! -f .extracted ]; then
	rm -rf ccache ccache-${CCACHE_VERSION}
	tar xvJf ccache-${CCACHE_VERSION}.tar.xz
	mv ccache-${CCACHE_VERSION} ccache
	touch .extracted
fi

cd ccache

if [ "$DESTARCH" == "mipsel" ]; then
	atomic="-latomic"
fi


if [ ! -f .configured ]; then
	cmake \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_INCLUDE_PATH=$DEST/include \
	-DCMAKE_LIBRARY_PATH=$DEST/lib \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$atomic $LDFLAGS" \
	-DREDIS_STORAGE_BACKEND=OFF \
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
Status "autoconf"

AUTOCONF_VERSION=2.71

cd $SRC/autoconf

if [ ! -f .extracted ]; then
	rm -rf autoconf autoconf-${AUTOCONF_VERSION}
	tar xvJf autoconf-${AUTOCONF_VERSION}.tar.xz
	mv autoconf-${AUTOCONF_VERSION} autoconf
	touch .extracted
fi

cd autoconf

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
Status "automake"

AUTOMAKE_VERSION=1.16.5

cd $SRC/automake

if [ ! -f .extracted ]; then
	rm -rf automake automake-${AUTOMAKE_VERSION}
	tar xvJf automake-${AUTOMAKE_VERSION}.tar.xz
	mv automake-${AUTOMAKE_VERSION} automake
	touch .extracted
fi

cd automake

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
Status "bison"

BISON_VERSION=3.8.2

cd $SRC/bison

if [ ! -f .extracted ]; then
	rm -rf bison bison-${BISON_VERSION}
	tar xvJf bison-${BISON_VERSION}.tar.xz
	mv bison-${BISON_VERSION} bison
	touch .extracted
fi

cd bison

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
Status "check"

CHECK_VERSION=0.10.0

cd $SRC/check

if [ ! -f .extracted ]; then
	rm -rf check check-${CHECK_VERSION}
	tar zxvf check-${CHECK_VERSION}.tar.gz
	mv check-${CHECK_VERSION} check
	touch .extracted
fi

cd check

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
Status "coreutils"

COREUTILS_VERSION=9.1

cd $SRC/coreutils

if [ ! -f .extracted ]; then
	rm -rf coreutils coreutils-${COREUTILS_VERSION}
	tar xvJf coreutils-${COREUTILS_VERSION}.tar.xz
	mv coreutils-${COREUTILS_VERSION} coreutils
	touch .extracted
fi

cd coreutils

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-single-binary=symlinks \
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
Status "diffutils"

DIFFUTILS_VERSION=3.8

cd $SRC/diffutils

if [ ! -f .extracted ]; then
	rm -rf diffutils diffutils-${DIFFUTILS_VERSION}
	tar xvJf diffutils-${DIFFUTILS_VERSION}.tar.xz
	mv diffutils-${DIFFUTILS_VERSION} diffutils
	touch .extracted
fi

cd diffutils

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
Status "findutils"

FINDUTILS_VERSION=4.9.0

cd $SRC/findutils

if [ ! -f .extracted ]; then
	rm -rf findutils findutils-${FINDUTILS_VERSION}
	tar xvJf findutils-${FINDUTILS_VERSION}.tar.xz
	mv findutils-${FINDUTILS_VERSION} findutils
	touch .extracted
fi

cd findutils

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
Status "gawk"

GAWK_VERSION=5.1.1

cd $SRC/gawk

if [ ! -f .extracted ]; then
	rm -rf gawk gawk-${GAWK_VERSION}
	tar xvJf gawk-${GAWK_VERSION}.tar.xz
	mv gawk-${GAWK_VERSION} gawk
	touch .extracted
fi

cd gawk

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
Status "libtool"

LIBTOOL_VERSION=2.4.7

cd $SRC/libtool

if [ ! -f .extracted ]; then
	rm -rf libtool libtool-${LIBTOOL_VERSION}
	tar xvJf libtool-${LIBTOOL_VERSION}.tar.xz
	mv libtool-${LIBTOOL_VERSION} libtool
	touch .extracted
fi

cd libtool

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
Status "slibtool"

SLIBTOOL_VERSION=0.5.34

cd $SRC/slibtool

if [ ! -f .extracted ]; then
	rm -rf slibtool slibtool-${SLIBTOOL_VERSION}
	tar xvJf slibtool-${SLIBTOOL_VERSION}.tar.xz
	mv slibtool-${SLIBTOOL_VERSION} slibtool
	touch .extracted
fi

cd slibtool

if [ ! -f .configured ]; then
	CC=$DESTARCH-tomatoware-linux-uclibc$GNUEABI-gcc \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --prefix=$PREFIX --host=$DESTARCH-tomatoware-linux-uclibc$GNUEABI
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
Status "m4"

M4_VERSION=1.4.19

cd $SRC/m4

if [ ! -f .extracted ]; then
	rm -rf m4 m4-${M4_VERSION}
	tar xvJf m4-${M4_VERSION}.tar.xz
	mv m4-${M4_VERSION} m4
	touch .extracted
fi

cd m4

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
Status "make"

MAKE_VERSION=4.3

cd $SRC/make

if [ ! -f .extracted ]; then
	rm -rf make make-${MAKE_VERSION}
	tar zxvf make-${MAKE_VERSION}.tar.gz
	mv make-${MAKE_VERSION} make
	touch .extracted
fi

cd make

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
Status "util-linux"

if [ "$DESTARCH" == "mipsel" ];then
	UTIL_LINUX_VERSION=2.34
else
	UTIL_LINUX_VERSION=2.38
fi

cd $SRC/util-linux

if [ ! -f .extracted ]; then
	rm -rf util-linux util-linux-${UTIL_LINUX_VERSION}
	tar xvJf util-linux-${UTIL_LINUX_VERSION}.tar.xz
	mv util-linux-${UTIL_LINUX_VERSION} util-linux
	touch .extracted
fi

cd util-linux

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
	--disable-rfkill \
	--disable-raw
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
Status "patch"

PATCH_VERSION=2.7.6

cd $SRC/patch

if [ ! -f .extracted ]; then
	rm -rf  patch patch-${PATCH_VERSION}
	tar xvJf patch-${PATCH_VERSION}.tar.xz
	mv patch-${PATCH_VERSION} patch
	touch .extracted
fi

cd patch

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
Status "wget"

WGET_VERSION=1.21.3

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/wget

if [ ! -f .extracted ]; then
	rm -rf wget wget-${WGET_VERSION}
	tar zxvf wget-${WGET_VERSION}.tar.gz
	mv wget-${WGET_VERSION} wget
	touch .extracted
fi

cd wget

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
Status "grep"

GREP_VERSION=3.7

cd $SRC/grep

if [ ! -f .extracted ]; then
	rm -rf grep grep-${GREP_VERSION}
	tar xvJf grep-${GREP_VERSION}.tar.xz
	mv grep-${GREP_VERSION} grep
	touch .extracted
fi

cd grep

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
Status "tar"

TAR_VERSION=1.34

cd $SRC/tar

if [ ! -f .extracted ]; then
	rm -rf tar tar-${TAR_VERSION}
	tar xvJf tar-${TAR_VERSION}.tar.xz
	mv tar-${TAR_VERSION} tar
	touch .extracted
fi

cd tar

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/tar/tar-1.33-remove-o_path-usage.patch
	touch .patched
fi

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
Status "sed"

SED_VERSION=4.8

cd $SRC/sed

if [ ! -f .extracted ]; then
	rm -rf sed sed-${SED_VERSION}
	tar xvJf sed-${SED_VERSION}.tar.xz
	mv sed-${SED_VERSION} sed
	touch .extracted
fi

cd sed

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
Status "texinfo"

TEXINFO_VERSION=6.8

cd $SRC/texinfo

if [ ! -f .extracted ]; then
	rm -rf texinfo texinfo-${TEXINFO_VERSION}
	tar xvJf texinfo-${TEXINFO_VERSION}.tar.xz
	mv texinfo-${TEXINFO_VERSION} texinfo
	touch .extracted
fi

cd texinfo

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
Status "cpio"

CPIO_VERSION=2.13

cd $SRC/cpio

if [ ! -f .extracted ]; then
	rm -rf cpio cpio-${CPIO_VERSION}
	tar xvjf cpio-${CPIO_VERSION}.tar.bz2
	mv cpio-${CPIO_VERSION} cpio
	touch .extracted
fi

cd cpio

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
Status "file"

FILE_VERSION=5.41

cd $SRC/file

if [ ! -f .extracted ]; then
	rm -rf file file-host file-${FILE_VERSION}
	tar zxvf file-${FILE_VERSION}.tar.gz
	mv file-${FILE_VERSION} file
	cp -r file file-host
	touch .extracted
fi

cd file-host

if [ ! -f .built-host ]; then
	autoreconf -f -i
	./configure \
	--prefix=$SRC/file/file-host
	$MAKE
	make install
	touch .built-host
fi

cd ../file

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
	PATH=$SRC/file/file-host/bin:$PATH \
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
Status "distcc"

DISTCC_VERSION=3.4

cd $SRC/distcc

if [ ! -f .extracted ]; then
	rm -rf distcc distcc-${DISTCC_VERSION}
	tar zxvf distcc-${DISTCC_VERSION}.tar.gz
	mv distcc-${DISTCC_VERSION} distcc
	touch .extracted
fi

cd distcc

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
Status "upx"

UCL_VERSION=1.03
UPX_VERSION=3.94

export UPX_UCLDIR=$SRC/upx/ucl

cd $SRC/upx

if [ ! -f .extracted ]; then
	rm -rf ucl upx ucl-${UCL_VERSION} upx-${UPX_VERSION}-src
	tar zxvf ucl-${UCL_VERSION}.tar.gz
	tar xvJf upx-${UPX_VERSION}-src.tar.xz
	mv ucl-${UCL_VERSION} ucl
	mv upx-${UPX_VERSION}-src upx
	touch .extracted
fi

cd ucl

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
Status "gdb"

GDB_VERSION=7.12.1

cd $SRC/gdb

if [ ! -f .extracted ]; then
	rm -rf gdb gdb-${GDB_VERSION}
	tar xvJf gdb-${GDB_VERSION}.tar.xz
	mv gdb-${GDB_VERSION} gdb
	touch .extracted
fi

cd gdb

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
Status "less"

LESS_VERSION=590

cd $SRC/less

if [ ! -f .extracted ]; then
	rm -rf less less-${LESS_VERSION}
	tar zxvf less-${LESS_VERSION}.tar.gz
	mv less-${LESS_VERSION} less
	touch .extracted
fi

cd less

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
Status "mandoc"

MANDOC_VERSION=1.14.6

cd $SRC/mandoc

if [ ! -f .extracted ]; then
	rm -rf mandoc mandoc-${MANDOC_VERSION}
	tar zxvf mandoc-${MANDOC_VERSION}.tar.gz
	mv mandoc-${MANDOC_VERSION} mandoc
	cp $SRC/mandoc/config.h mandoc
	cp $SRC/mandoc/Makefile.local mandoc
	sed -i 's,mmc,'"${PREFIX#"/"}"',g' $SRC/mandoc/mandoc/config.h
	touch .extracted
fi

cd mandoc

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
Status "dpkg"

DPKG_VERSION=1.21.7

cd $SRC/dpkg

if [ ! -f .extracted ]; then
	rm -rf dpkg dpkg-${DPKG_VERSION}
	tar xvJf dpkg-${DPKG_VERSION}.tar.xz
	mv dpkg-${DPKG_VERSION} dpkg
	touch .extracted
fi

cd dpkg

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/dpkg/dpkg-silence-warnings.patch
	touch .patched
fi


if [ ! -f .configured ]; then
	PATH=$SRC/perl/native/bin:$PATH \
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
	ln -sf true $DEST/bin/ldconfig
	touch .ldconfig
fi

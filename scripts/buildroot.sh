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

######## ####################################################################
# GLIB # ####################################################################
######## ####################################################################

GLIB_VERSION=2.26.1

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/glib

if [ ! -f .extracted ]; then
	rm -rf glib-${GLIB_VERSION}
	tar zxvf glib-${GLIB_VERSION}.tar.gz
	touch .extracted
fi

cd glib-${GLIB_VERSION}

if [ ! -f .patched ]; then
	patch < $PATCHES/glib/001-automake-compat.patch
	patch -p1 < $PATCHES/glib/002-missing-gthread-include.patch
	patch < $PATCHES/glib/010-move-iconv-to-libs.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-libiconv=gnu  \
	--enable-static \
	glib_cv_stack_grows=no \
	glib_cv_uscore=no \
	ac_cv_func_posix_getpwuid_r=yes \
	ac_cv_func_posix_getgrgid_r=yes
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

if [ ! -f .edit_sed ]; then
	sed -i 's,'"$PREFIX"'\/lib\/libintl.la,'"$DEST"'\/lib\/libintl.la,g;s,'"$PREFIX"'\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
	$DEST/lib/libglib-2.0.la
	touch .edit_sed
fi

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

GMP_VERSION=6.1.2

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

MPFR_VERSION=4.0.1

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

MPC_VERSION=1.1.0

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

BINUTILS_VERSION=2.31.1

mkdir -p $SRC/binutils && cd $SRC/binutils

if [ ! -f .extracted ]; then
	rm -rf binutils-${BINUTILS_VERSION} build-binutils
	tar xvJf $SRC/toolchain/dl/binutils/binutils-${BINUTILS_VERSION}.tar.xz -C $SRC/binutils
	mkdir build-binutils
	touch .extracted
fi

cd build-binutils

if [ "$DESTARCH" == "mipsel" ];then
        os=mipsel-buildroot-linux-uclibc
fi

if [ "$DESTARCH" == "arm" ];then
	os=arm-buildroot-linux-uclibcgnueabi
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	../binutils-${BINUTILS_VERSION}/configure --prefix=$PREFIX --host=$os --target=$os \
	--with-sysroot=$PREFIX \
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

####### #####################################################################
# GCC # #####################################################################
####### #####################################################################

GCC_VERSION=8.2.0

mkdir -p $SRC/gcc && cd $SRC/gcc

if [ ! -f .extracted ]; then
	rm -rf gcc-${GCC_VERSION} gcc-build
	tar xvJf $SRC/toolchain/dl/gcc/gcc-${GCC_VERSION}.tar.xz -C $SRC/gcc
	mkdir gcc-build
	touch .extracted
fi

cd gcc-${GCC_VERSION}

if [ ! -f .patched ]; then
	cp $PATCHES/gcc/gcc-7.3.0-specs-1.patch .
	sed -i 's,\/opt,'"$PREFIX"',g' gcc-7.3.0-specs-1.patch
	patch -p1 < gcc-7.3.0-specs-1.patch
	patch -p1 < $PATCHES/gcc/0810-arm-softfloat-libgcc.patch
	touch .patched
fi

cd ../gcc-build

if [ "$DESTARCH" == "mipsel" ]; then
	os=mipsel-buildroot-linux-uclibc
	gccextraconfig="--with-abi=32
			--with-arch=mips32"
fi

if [ "$DESTARCH" == "arm" ];then
	os=arm-buildroot-linux-uclibcgnueabi
	gccextraconfig="--with-abi=aapcs-linux
			--with-cpu=cortex-a9
			--with-mode=arm"
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
	--enable-languages=c,c++ \
	--enable-shared \
	--enable-static \
	--enable-threads=posix \
	--enable-tls \
	--enable-version-specific-runtime-libs \
	--with-float=soft \
	--with-gnu-as \
	--with-gnu-ld \
	--disable-__cxa_atexit \
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

if [ ! -f $DEST/bin/cc ]; then
	ln -s gcc $DEST/bin/cc
fi

if [ ! -f $DEST/bin/$DESTARCH-linux-gcc ]; then
	ln -s gcc $DEST/bin/$DESTARCH-linux-gcc
fi

if [ ! -f $DEST/bin/$DESTARCH-linux-g++ ]; then
	ln -s g++ $DEST/bin/$DESTARCH-linux-g++
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

AUTOMAKE_VERSION=1.16.1

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

BISON_VERSION=3.1

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

COREUTILS_VERSION=8.25

cd $SRC/coreutils

if [ ! -f .extracted ]; then
	rm -rf coreutils-${COREUTILS_VERSION}
	tar xvJf coreutils-${COREUTILS_VERSION}.tar.xz
	touch .extracted
fi

cd coreutils-${COREUTILS_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/coreutils/002-fix_compile_with_uclibc.patch
	patch -p1 < $PATCHES/coreutils/man-decouple-manpages-from-build.patch
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

DIFFUTILS_VERSION=3.6

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

FINDUTILS_VERSION=4.5.19

cd $SRC/findutils

if [ ! -f .extracted ]; then
	rm -rf findutils-${FINDUTILS_VERSION}
	tar zxvf findutils-${FINDUTILS_VERSION}.tar.gz
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

GAWK_VERSION=4.2.1

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

MAKE_VERSION=4.2.1

cd $SRC/make

if [ ! -f .extracted ]; then
	rm -rf make-${MAKE_VERSION}
	tar xvjf make-${MAKE_VERSION}.tar.bz2
	touch .extracted
fi

cd make-${MAKE_VERSION}

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
# CMAKE # ###################################################################
######### ###################################################################

CMAKE_VERSION=3.12.2

cd $SRC/cmake

if [ ! -f .extracted ]; then
	rm -rf cmake-${CMAKE_VERSION} cmake-${CMAKE_VERSION}-native
	tar zxvf cmake-${CMAKE_VERSION}.tar.gz
	cp -r cmake-${CMAKE_VERSION} cmake-${CMAKE_VERSION}-native
	touch .extracted
fi

cd cmake-${CMAKE_VERSION}-native

if [ ! -f .built-native ]; then
	./configure \
	--prefix=$SRC/cmake/cmake-${CMAKE_VERSION}-native
	$MAKE
	make install
	touch .built-native
fi

cd ../cmake-${CMAKE_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/cmake/cmake.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	PATH=$SRC/cmake/cmake-${CMAKE_VERSION}-native/bin:$PATH \
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

############## ##############################################################
# UTIL-LINUX # ##############################################################
############## ##############################################################

UTIL_LINUX_VERSION=2.32

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

WGET_VERSION=1.19.5

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

GREP_VERSION=3.1

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

TAR_VERSION=1.30

cd $SRC/tar

if [ ! -f .extracted ]; then
	rm -rf tar-${TAR_VERSION}
	tar xvJf tar-${TAR_VERSION}.tar.xz
	touch .extracted
fi

cd tar-${TAR_VERSION}

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
# SED # #####################################################################
####### #####################################################################

SED_VERSION=4.5

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

TEXINFO_VERSION=6.5

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

CPIO_VERSION=2.12

cd $SRC/cpio

if [ ! -f .extracted ]; then
	rm -rf cpio-${CPIO_VERSION}
	tar xvjf cpio-${CPIO_VERSION}.tar.bz2
	touch .extracted
fi

cd cpio-${CPIO_VERSION}

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
# FILE # ####################################################################
######## ####################################################################

FILE_VERSION=5.34

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

DISTCC_VERSION=3.1

PYTHON_CROSS="PYTHONPATH=../../python/Python-2.7.3/Lib/:../../setuptools/setuptools ../../python/Python-2.7.3/hostpython"

cd $SRC/distcc

if [ ! -f .extracted ]; then
	rm -rf distcc-distcc-${DISTCC_VERSION}
	tar zxvf distcc-${DISTCC_VERSION}.tar.gz
	touch .extracted
fi

cd distcc-distcc-${DISTCC_VERSION}

if [ ! -f .configured ]; then
	./autogen.sh
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-Werror
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE \
	PYTHON="$PYTHON_CROSS" \
	TEST_PYTHON="$PYTHON_CROSS" \
	INCLUDESERVER_PYTHON="$PYTHON_CROSS"
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

unset PYTHON_CROSS

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

LESS_VERSION=530

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

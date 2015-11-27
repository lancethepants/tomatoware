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

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/glib

if [ ! -f .extracted ]; then
	rm -rf glib-2.26.1
	tar zxvf glib-2.26.1.tar.gz
	touch .extracted
fi

cd glib-2.26.1

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

cd $SRC/pkg-config

if [ ! -f .extracted ]; then
	rm -rf pkg-config-0.29
	tar zxvf pkg-config-0.29.tar.gz
	touch .extracted
fi

cd pkg-config-0.29

if [ ! -f .configured ]; then
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

cd $SRC/gmp

if [ ! -f .extracted ]; then
	rm -rf gmp-6.1.0
	tar xvjf gmp-6.1.0.tar.bz2
	touch .extracted
fi

cd gmp-6.1.0

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

cd $SRC/mpfr

if [ ! -f .extracted ]; then
	rm -rf mpfr-3.1.3
	tar zxvf mpfr-3.1.3.tar.gz
	touch .extracted
fi

cd mpfr-3.1.3

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

cd $SRC/mpc

if [ ! -f .extracted ]; then
	rm -rf mpc-1.0.3
	tar zxvf mpc-1.0.3.tar.gz
	touch .extracted
fi

cd mpc-1.0.3

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

cd $SRC/binutils

if [ ! -f .extracted ]; then
	rm -rf binutils-2.24 build-binutils
	tar zxvf binutils-2.24.tar.gz
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
	../binutils-2.24/configure --prefix=$PREFIX --host=$os --target=$os \
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

mkdir -p $SRC/gcc && cd $SRC/gcc

if [ ! -f .extracted ]; then
	rm -rf gcc-5.2.0 gcc-build
	tar xvjf $SRC/toolchain/dl/gcc-5.2.0.tar.bz2 -C $SRC/gcc
	mkdir gcc-build
	touch .extracted
fi

cd gcc-5.2.0

if [ ! -f .patched ]; then
	cp $PATCHES/gcc/gcc-5.2.0-specs-1.patch .
	sed -i 's,\/opt,'"$PREFIX"',g' gcc-5.2.0-specs-1.patch
	patch -p1 < gcc-5.2.0-specs-1.patch
	touch .patched
fi

cd ../gcc-build

if [ "$DESTARCH" == "mipsel" ]; then
	os=mipsel-buildroot-linux-uclibc
	gccextraconfig="--with-arch=mips32 \
			--with-mips-plt"
fi

if [ "$DESTARCH" == "arm" ];then
	os=arm-buildroot-linux-uclibcgnueabi
	gccextraconfig="--with-abi=aapcs-linux
			--with-cpu=cortex-a9"
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	../gcc-5.2.0/configure --prefix=$PREFIX --host=$os --target=$os \
	--with-mpc-include=$DEST/include \
	--with-mpc-lib=$DEST/lib \
	--with-mpfr-include=$DEST/include \
	--with-mpfr-lib=$DEST/lib \
	--with-gmp-include=$DEST/include \
	--with-gmp-lib=$DEST/lib \
	--enable-version-specific-runtime-libs \
	--enable-languages=c,c++ \
	--enable-threads=posix \
	--enable-shared \
	--enable-tls \
	--with-gnu-as \
	--with-gnu-ld \
	--disable-nls \
	--disable-werror \
	--disable-libstdcxx-pch \
	--disable-libssp \
	--with-float=soft \
	--disable-libsanitizer \
	--disable-libgomp \
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

if [ "$DESTARCH" = "arm" ] && [ ! -f $DEST/bin/arm-linux-gcc ]; then
        ln -s gcc $DEST/bin/arm-linux-gcc
fi

############ ################################################################
# AUTOCONF # ################################################################
############ ################################################################

cd $SRC/autoconf

if [ ! -f .extracted ]; then
	rm -rf autoconf-2.69
	tar zxvf autoconf-2.69.tar.gz
	touch .extracted
fi

cd autoconf-2.69

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

cd $SRC/automake

if [ ! -f .extracted ]; then
	rm -rf automake-1.15
	tar zxvf automake-1.15.tar.gz
	touch .extracted
fi

cd automake-1.15

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

cd $SRC/bison

if [ ! -f .extracted ]; then
	rm -rf bison-3.0.4
	tar zxvf bison-3.0.4.tar.gz
	touch .extracted
fi

cd bison-3.0.4

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

cd $SRC/check

if [ ! -f .extracted ]; then
	rm -rf check-0.10.10
	tar zxvf check-0.10.0.tar.gz
	touch .extracted
fi

cd check-0.10.0

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

cd $SRC/coreutils

if [ ! -f .extracted ]; then
	rm -rf coreutils-8.24
	tar xvJf coreutils-8.24.tar.xz
	touch .extracted
fi

cd coreutils-8.24

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

cd $SRC/diffutils

if [ ! -f .extracted ]; then
	rm -rf diffutils-3.3
	tar xvJf diffutils-3.3.tar.xz
	touch .extracted
fi

cd diffutils-3.3

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

cd $SRC/findutils

if [ ! -f .extracted ]; then
	rm -rf findutils-4.5.14
	tar zxvf findutils-4.5.14.tar.gz
	touch .extracted
fi

cd findutils-4.5.14

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

cd $SRC/gawk

if [ ! -f .extracted ]; then
	rm -rf gawk-4.1.3
	tar zxvf gawk-4.1.3.tar.gz
	touch .extracted
fi

cd gawk-4.1.3

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

cd $SRC/libtool

if [ ! -f .extracted ]; then
	rm -rf libtool-2.4.6
	tar zxvf libtool-2.4.6.tar.gz
	touch .extracted
fi

cd libtool-2.4.6

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

cd $SRC/m4

if [ ! -f .extracted ]; then
	rm -rf m4-1.4.17
	tar zxvf m4-1.4.17.tar.gz
	touch .extracted
fi

cd m4-1.4.17

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

cd $SRC/make

if [ ! -f .extracted ]; then
	rm -rf make-4.1
	tar zxvf make-4.1.tar.gz
	touch .extracted
fi

cd make-4.1

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

cd $SRC/cmake

if [ ! -f .extracted ]; then
	rm -rf cmake-3.4.0
	tar zxvf cmake-3.4.0.tar.gz
	touch .extracted
fi

cd cmake-3.4.0

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/cmake/cmake.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_C_COMPILER=$DESTARCH-linux-gcc \
	-DCMAKE_CXX_COMPILER=$DESTARCH-linux-g++ \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
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

cd $SRC/util-linux

if [ ! -f .extracted ]; then
	rm -rf util-linux-2.27
	tar zxvf util-linux-2.27.tar.gz
	touch .extracted
fi

cd util-linux-2.27

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
	--disable-wall
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

cd $SRC/patch

if [ ! -f .extracted ]; then
	rm -rf  patch-2.7.5
	tar zxvf patch-2.7.5.tar.gz
	touch .extracted
fi

cd patch-2.7.5

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

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/wget

if [ ! -f .extracted ]; then
	rm -rf wget-1.17
	tar zxvf wget-1.17.tar.gz
	touch .extracted
fi

cd wget-1.17

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

cd $SRC/grep

if [ ! -f .extracted ]; then
	rm -rf grep-2.21
	tar xvJf grep-2.21.tar.xz
	touch .extracted
fi
 
cd grep-2.21

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

cd $SRC/tar

if [ ! -f .extracted ]; then
	rm -rf tar-1.28
	tar zxvf tar-1.28.tar.gz
	touch .extracted
fi

cd tar-1.28

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

cd $SRC/sed

if [ ! -f .extracted ]; then
        rm -rf sed-4.2.2
        tar zxvf sed-4.2.2.tar.gz
        touch .extracted
fi

cd sed-4.2.2

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

cd $SRC/texinfo

if [ ! -f .extracted ]; then
        rm -rf texinfo-6.0
        tar zxvf texinfo-6.0.tar.gz
        touch .extracted
fi

cd texinfo-6.0

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

cd $SRC/cpio

if [ ! -f .extracted ]; then
	rm -rf cpio-2.12
	tar zxvf cpio-2.12.tar.gz
	touch .extracted
fi

cd cpio-2.12

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
# UPX # #####################################################################
####### #####################################################################

cd $SRC/upx

if [ ! -f .extracted ] && [ "$DESTARCH" == "mipsel" ]; then
	rm -rf upx-3.91-mipsel_linux
	tar xvjf upx-3.91-mipsel_linux.tar.bz2
	touch .extracted
fi

if [ ! -f .installed ] && [ "$DESTARCH" == "mipsel" ]; then
	cp ./upx-3.91-mipsel_linux/upx $DEST/bin
	touch .installed
fi

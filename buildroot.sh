#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=$BASE/src
PATCHES=$BASE/patches
RPATH=/opt/lib
DEST=$BASE/opt
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
CPPFLAGS="-I$DEST/include -I$DEST/include/ncurses"
CFLAGS="-mtune=mips32 -mips32"
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make -j`nproc`"

######## ####################################################################
# GLIB # ####################################################################
######## ####################################################################

if [ ! -f .exported ]; then
	export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig
	touch .exported
fi

cd $SRC/glib

if [ ! -f .extracted ]; then
	rm -rf glib-2.26.1
	tar zxvf glib-2.26.1.tar.gz
	touch .extracted
fi

cd glib-2.26.1

if [ ! -f .patched ]; then
	patch < $PATCHES/001-automake-compat.patch
	patch -p1 < $PATCHES/002-missing-gthread-include.patch
	patch < $PATCHES/010-move-iconv-to-libs.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	$CONFIGURE \
	--with-libiconv=gnu  \
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

if [ ! -f .de-exported ]; then
	unset PKG_CONFIG_LIBDIR
	touch .de-exported
fi

############## ##############################################################
# PKG-CONFIG # ##############################################################
############## ##############################################################

if [ ! -f .edit_sed ]; then
	sed -i 's,\/opt\/lib\/libiconv.la \/opt\/lib\/libintl.la -lc,'"$DEST"'\/lib\/libiconv.la '"$DEST"'\/lib\/libintl.la -lc,g' \
	$DEST/lib/libglib-2.0.la
	touch .edit_sed
fi

cd $SRC/pkg-config

if [ ! -f .extracted ]; then
	rm -rf pkg-config-0.28
	tar zxvf pkg-config-0.28.tar.gz
	touch .extracted
fi

cd pkg-config-0.28

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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

if [ ! -f .restore_sed ]; then
	sed -i 's,'"$DEST"'\/lib\/libiconv.la '"$DEST"'\/lib\/libintl.la -lc,\/opt\/lib\/libiconv.la \/opt\/lib\/libintl.la -lc,g' \
	$DEST/lib/libglib-2.0.la
	touch .restore_sed
fi

####### #####################################################################
# GMP # #####################################################################
####### #####################################################################

cd $SRC/gmp

if [ ! -f .extracted ]; then
	rm -rf gmp-5.1.2
	tar xvjf gmp-5.1.2.tar.bz2
	touch .extracted
fi

cd gmp-5.1.2

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
	rm -rf mpfr-3.1.2
	tar zxvf mpfr-3.1.2.tar.gz
	touch .extracted
fi

cd mpfr-3.1.2

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
# MPC # #####################################################################
####### #####################################################################

if [ ! -f .edit_sed ]; then
	sed -i 's,\/opt\/lib\/libgmp.la,'"$DEST"'\/lib\/libgmp.la,g' \
	$DEST/lib/libmpfr.la
	touch .edit_sed
fi

cd $SRC/mpc

if [ ! -f .extracted ]; then
	rm -rf mpc-1.0.1
	tar zxvf mpc-1.0.1.tar.gz
	touch .extracted
fi

cd mpc-1.0.1

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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

if [ ! -f .restore_sed ]; then
	sed -i 's,'"$DEST"'\/lib\/libgmp.la,\/opt\/lib\/libgmp.la,g' \
	$DEST/lib/libmpfr.la
	touch .restore_sed
fi

############ ################################################################
# BINUTILS # ################################################################
############ ################################################################

cd $SRC/binutils

if [ ! -f .extracted ]; then
	rm -rf binutils-2.23.2 build-binutils
	tar zxvf binutils-2.23.2.tar.gz
	mkdir build-binutils
	touch .extracted
fi

cd build-binutils

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	../binutils-2.23.2/$CONFIGURE \
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

cd $SRC/gcc

if [ ! -f .extracted ]; then
	rm -rf gcc-4.6.3 gcc-build
	tar zxvf gcc-4.6.3.tar.gz
	mkdir gcc-build
	touch .extracted
fi

cd gcc-4.6.3

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/gcc-4.6.3-specs-1.patch
	touch .patched
fi

cd ../gcc-build

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	../gcc-4.6.3/$CONFIGURE --target=mipsel-linux \
	--with-mpc-include=$DEST/include \
	--with-mpc-lib=$DEST/lib \
	--with-mpfr-include=$DEST/include \
	--with-mpfr-lib=$DEST/lib \
	--with-gmp-include=$DEST/include \
	--with-gmp-lib=$DEST/lib \
	--enable-version-specific-runtime-libs \
	--enable-languages=c,c++ \
	--with-gnu-as --with-gnu-ld --disable-nls -enable-werror=no --disable-libstdcxx-pch
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
	rm -rf automake-1.13.3
	tar zxvf automake-1.13.3.tar.gz
	touch .extracted
fi

cd automake-1.13.3

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
	rm -rf bison-2.7.1
	tar zxvf bison-2.7.1.tar.gz
	touch .extracted
fi

cd bison-2.7.1

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
	rm -rf check-0.9.10
	tar zxvf check-0.9.10.tar.gz
	touch .extracted
fi

cd check-0.9.10

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
	rm -rf coreutils-8.21
	tar xvJf coreutils-8.21.tar.xz 
	touch .extracted
fi

cd coreutils-8.21

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/002-fix_compile_with_uclibc.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	$CONFIGURE \
	--enable-install-program=hostname \
	fu_cv_sys_stat_statfs2_bsize=yes \
	gl_cv_func_working_mkstemp=yes
	touch .configured
fi

if [ ! -f .edit_sed ]; then
	cp -v Makefile{,.orig}
	sed -e 's/^#run_help2man\|^run_help2man/#&/' \
	  -e 's/^\##run_help2man/run_help2man/' Makefile.orig > Makefile
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
	rm -rf findutils-4.4.2
	tar zxvf findutils-4.4.2.tar.gz
	touch .extracted
fi

cd findutils-4.4.2

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
# FLEX # ####################################################################
######## ####################################################################

cd $SRC/flex

if [ ! -f .extracted ]; then
	rm -rf flex-2.5.37
	tar zxvf flex-2.5.37.tar.gz
	touch .extracted
fi

cd flex-2.5.37

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
# GAWK # ####################################################################
######## ####################################################################

cd $SRC/gawk

if [ ! -f .extracted ]; then
	rm -rf gawk-4.1.0
	tar zxvf gawk-4.1.0.tar.gz
	touch .extracted
fi

cd gawk-4.1.0

if [ ! -f .edit_sed ]; then
	cp -v extension/Makefile.in{,.orig}
	sed -e 's/check-recursive all-recursive: check-for-shared-lib-support/check-recursive all-recursive:/' extension/Makefile.in.orig > extension/Makefile.in
	touch .edit_sed
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
	rm -rf libtool-2.4.2
	tar zxvf libtool-2.4.2.tar.gz
	touch .extracted
fi

cd libtool-2.4.2

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
	rm -rf m4-1.4.16
	tar zxvf m4-1.4.16.tar.gz
	touch .extracted
fi

cd m4-1.4.16

if [ ! -f .configured ]; then
LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
	rm -rf make-3.82
	tar zxvf make-3.82.tar.gz
	touch .extracted
fi

cd make-3.82

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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

############## ##############################################################
# UTIL-LINUX # ##############################################################
############## ##############################################################

cd $SRC/util-linux

if [ ! -f .extracted ]; then
	rm -rf util-linux-2.21.2
	tar zxvf util-linux-2.21.2.tar.gz
	touch .extracted
fi

cd util-linux-2.21.2

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/000-compile.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	$CONFIGURE \
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
	rm -rf  patch-2.7.1
	tar zxvf patch-2.7.1.tar.gz
	touch .extracted
fi

cd patch-2.7.1

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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

cd $SRC/wget

if [ ! -f .extracted ]; then
	rm -rf wget-1.14
	tar zxvf wget-1.14.tar.gz
	touch .extracted
fi

cd wget-1.14

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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

######## ####################################################################
# GREP # ####################################################################
######## ####################################################################

cd $SRC/grep

if [ ! -f .extracted ]; then
	rm -rf grep-2.14
	tar xvJf grep-2.14.tar.xz
	touch .extracted
fi
 
cd grep-2.14

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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
	rm -rf tar-1.26
	tar zxvf tar-1.26.tar.gz
	touch .extracted
fi

cd tar-1.26

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
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

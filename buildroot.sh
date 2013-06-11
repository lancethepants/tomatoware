#!/bin/bash

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
PATCHES=$BASE/patches
RPATH=/opt/lib
DEST=$BASE/opt
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 -Wl,--gc-sections -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
CPPFLAGS="-I$DEST/include -I$DEST/include/ncurses"
CFLAGS="-DBCMWPA2 -funit-at-a-time -Wno-pointer-sign -mtune=mips32 -mips32"
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make -j`nproc`"
echo "`nproc` CPU(S) detected"
echo "Will use parallel building if available"
sleep 5 

mkdir -p $SRC

export PATH=$PATH:/opt/entware-toolchain/bin/:/opt/entware-toolchain/mipsel-linux/bin/

######## ####################################################################
# GLIB # ####################################################################
######## ####################################################################

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/glib
tar zxvf glib-2.26.1.tar.gz
cd glib-2.26.1

patch < $PATCHES/001-automake-compat.patch
patch -p1 < $PATCHES/002-missing-gthread-include.patch
patch < $PATCHES/010-move-iconv-to-libs.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-libiconv=gnu  \
glib_cv_stack_grows=no \
glib_cv_uscore=no \
ac_cv_func_posix_getpwuid_r=yes \
ac_cv_func_posix_getgrgid_r=yes

$MAKE
make install DESTDIR=$BASE

unset PKG_CONFIG_LIBDIR

############## ##############################################################
# PKG-CONFIG # ##############################################################
############## ##############################################################

sed -i 's,\/opt\/lib\/libiconv.la \/opt\/lib\/libintl.la -lc,'"$DEST"'\/lib\/libiconv.la '"$DEST"'\/lib\/libintl.la -lc,g' \
$DEST/lib/libglib-2.0.la

cd $SRC/pkg-config
tar zxvf pkg-config-0.28.tar.gz
cd pkg-config-0.28

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-pc-path=$DEST/lib/pkgconfig

$MAKE
make install DESTDIR=$BASE

sed -i 's,'"$DEST"'\/lib\/libiconv.la '"$DEST"'\/lib\/libintl.la -lc,\/opt\/lib\/libiconv.la \/opt\/lib\/libintl.la -lc,g' \
$DEST/lib/libglib-2.0.la

####### #####################################################################
# GMP # #####################################################################
####### #####################################################################

cd $SRC/gmp
tar xvjf gmp-5.1.2.tar.bz2
cd gmp-5.1.2

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-cxx

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# MPFR # ####################################################################
######## ####################################################################

cd $SRC/mpfr
tar zxvf mpfr-3.1.2.tar.gz
cd mpfr-3.1.2

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# MPC # #####################################################################
####### #####################################################################

sed -i 's,\/opt\/lib\/libgmp.la,'"$DEST"'\/lib\/libgmp.la,g' \
$DEST/lib/libmpfr.la

cd $SRC/mpc
tar zxvf mpc-1.0.1.tar.gz
cd mpc-1.0.1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-mpfr=$DEST \
--with-gmp=$DEST

$MAKE
make install DESTDIR=$BASE

sed -i 's,'"$DEST"'\/lib\/libgmp.la,\/opt\/lib\/libgmp.la,g' \
$DEST/lib/libmpfr.la

############ ################################################################
# BINUTILS # ################################################################
############ ################################################################

cd $SRC/binutils
tar zxvf binutils-2.23.2.tar.gz
mkdir build-binutils && cd build-binutils

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
../binutils-2.23.2/$CONFIGURE \
--disable-werror \
--disable-nls

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# GCC # #####################################################################
####### #####################################################################

cd $SRC/gcc
tar zxvf gcc-4.6.4.tar.gz

cd gcc-4.6.4
patch -p1 < $PATCHES/gcc-4.6.3-specs-1.patch
cd ..

mkdir gcc-build && cd gcc-build

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
../gcc-4.6.4/$CONFIGURE --target=mipsel-linux \
--with-mpc-include=$DEST/include \
--with-mpc-lib=$DEST/lib \
--with-mpfr-include=$DEST/include \
--with-mpfr-lib=$DEST/lib \
--with-gmp-include=$DEST/include \
--with-gmp-lib=$DEST/lib \
--enable-version-specific-runtime-libs \
--enable-languages=c,c++ \
--with-gnu-as --with-gnu-ld --disable-nls -enable-werror=no --disable-libstdcxx-pch

$MAKE
make install DESTDIR=$BASE

ln -s gcc $DEST/bin/cc

############ ################################################################
# AUTOCONF # ################################################################
############ ################################################################

cd $SRC/autoconf
tar zxvf autoconf-2.69.tar.gz
cd autoconf-2.69

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

############ ################################################################
# AUTOMAKE # ################################################################
############ ################################################################

cd $SRC/automake
tar zxvf automake-1.12.4.tar.gz
cd automake-1.12.4

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

######### ###################################################################
# BISON # ###################################################################
######### ###################################################################

cd $SRC/bison
tar zxvf bison-2.6.5.tar.gz
cd bison-2.6.5

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

######### ###################################################################
# CHECK # ###################################################################
######### ###################################################################

cd $SRC/check
tar zxvf check-0.9.9.tar.gz
cd check-0.9.9

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

############# ###############################################################
# COREUTILS # ###############################################################
############# ###############################################################

cd $SRC/coreutils
tar xvJf coreutils-8.16.tar.xz
cd coreutils-8.16

patch -p1 < $PATCHES/002-fix_compile_with_uclibc.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-install-program=hostname \
fu_cv_sys_stat_statfs2_bsize=yes \
gl_cv_func_working_mkstemp=yes

$MAKE
make install DESTDIR=$BASE

############# ###############################################################
# DIFFUTILS # ###############################################################
############# ###############################################################

cd $SRC/diffutils
tar zxvf diffutils-3.2.tar.gz
cd diffutils-3.2

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

############# ###############################################################
# FINDUTILS # ###############################################################
############# ###############################################################

cd $SRC/findutils
tar zxvf findutils-4.4.2.tar.gz
cd findutils-4.4.2

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
gl_cv_func_wcwidth_works=yes

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# FLEX # ####################################################################
######## ####################################################################

cd $SRC/flex
tar zxvf flex-2.5.37.tar.gz
cd flex-2.5.37

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# GAWK # ####################################################################
######## ####################################################################

cd $SRC/gawk
tar zxvf gawk-4.0.1.tar.gz
cd gawk-4.0.1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# LIBTOOL # #################################################################
########### #################################################################

cd $SRC/libtool
tar zxvf libtool-2.4.2.tar.gz
cd libtool-2.4.2

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

###### ######################################################################
# M4 # ######################################################################
###### ######################################################################

cd $SRC/m4
tar zxvf m4-1.4.16.tar.gz
cd m4-1.4.16

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# MAKE # ####################################################################
######## ####################################################################

cd $SRC/make
tar zxvf make-3.82.tar.gz
cd make-3.82

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

############## ##############################################################
# UTIL-LINUX # ##############################################################
############## ##############################################################

cd $SRC/util-linux
tar zxvf util-linux-2.21.2.tar.gz
cd util-linux-2.21.2

patch -p1 < $PATCHES/000-compile.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--disable-nls \
--disable-wall

$MAKE
make install DESTDIR=$BASE

######### ###################################################################
# PATCH # ###################################################################
######### ###################################################################

cd $SRC/patch
tar zxvf patch-2.7.1.tar.gz
cd patch-2.7.1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# WGET # ####################################################################
######## ####################################################################

cd $SRC/wget
tar zxvf wget-1.14.tar.gz
cd wget-1.14

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-ssl=openssl

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# GREP # ####################################################################
######## ####################################################################

cd $SRC/grep
tar zxvf grep-2.9.tar.gz
cd grep-2.9

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# TAR # #####################################################################
####### #####################################################################

cd $SRC/tar
tar zxvf tar-1.26.tar.gz
cd tar-1.26

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

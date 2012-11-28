#!/bin/sh

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
MAKE="make -j2"

mkdir -p $SRC

if [ ! -d toolchain ]
then
$WGET http://wl500g-repo.googlecode.com/files/entware-toolchain-r4667-amd64.tgz
tar zxvf entware-toolchain-r4667-amd64.tgz
mv opt/entware-toolchain/ ./toolchain
rm -rf opt/ entware-toolchain-r4667-amd64.tgz
fi

export PATH=$PATH:$BASE/toolchain/bin:$BASE/toolchain/mipsel-linux/bin

######## ####################################################################
# GLIB # ####################################################################
######## ####################################################################

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC
mkdir glib && cd glib
$WGET http://ftp.acc.umu.se/pub/gnome/sources/glib/2.26/glib-2.26.1.tar.gz
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

cd $SRC
mkdir pkg-config && cd pkg-config
$WGET http://pkgconfig.freedesktop.org/releases/pkg-config-0.27.tar.gz
tar zxvf pkg-config-0.27.tar.gz
cd pkg-config-0.27

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

cd $SRC
mkdir gmp && cd gmp
$WGET ftp://ftp.gmplib.org/pub/gmp-5.0.5/gmp-5.0.5.tar.bz2
tar xvjf gmp-5.0.5.tar.bz2
cd gmp-5.0.5

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

cd $SRC
mkdir mpfr && cd mpfr
$WGET http://www.mpfr.org/mpfr-current/mpfr-3.1.1.tar.gz
tar zxvf mpfr-3.1.1.tar.gz
cd mpfr-3.1.1

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

cd $SRC
mkdir mpc && cd mpc
$WGET http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz
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

cd $SRC
mkdir binutils && cd binutils
$WGET http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz
tar zxvf binutils-2.22.tar.gz
mkdir build-binutils && cd build-binutils

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
../binutils-2.22/$CONFIGURE \
--disable-werror \
--disable-nls

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# GCC # #####################################################################
####### #####################################################################

cd $SRC
mkdir gcc && cd gcc
$WGET http://www.netgull.com/gcc/releases/gcc-4.6.3/gcc-4.6.3.tar.gz
tar zxvf gcc-4.6.3.tar.gz

mkdir gcc-build && cd gcc-build

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

$MAKE
make install DESTDIR=$BASE

############ ################################################################
# AUTOCONF # ################################################################
############ ################################################################

cd $SRC
mkdir autoconf && cd autoconf
$WGET http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
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

cd $SRC
mkdir automake && cd automake
$WGET http://ftp.gnu.org/gnu/automake/automake-1.12.4.tar.gz
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

cd $SRC
mkdir bison && cd bison
$WGET http://ftp.gnu.org/gnu/bison/bison-2.6.5.tar.gz
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

cd $SRC
mkdir check && cd check
$WGET http://downloads.sourceforge.net/project/check/check/0.9.9/check-0.9.9.tar.gz
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

cd $SRC
mkdir coreutils && cd coreutils
$WGET http://ftp.gnu.org/gnu/coreutils/coreutils-8.16.tar.xz
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

cd $SRC
mkdir diffutils && cd diffutils
$WGET http://ftp.gnu.org/gnu/diffutils/diffutils-3.2.tar.gz
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

cd $SRC
mkdir findutils && cd findutils
$WGET http://ftp.gnu.org/pub/gnu/findutils/findutils-4.4.2.tar.gz
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

cd $SRC
mkdir flex && cd flex
$WGET http://downloads.sourceforge.net/project/flex/flex-2.5.37.tar.gz
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

cd $SRC
mkdir gawk && cd gawk
$WGET http://ftp.gnu.org/gnu/gawk/gawk-4.0.1.tar.gz
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

cd $SRC
mkdir libtool && cd  libtool
$WGET http://gnu.mirrors.pair.com/gnu/libtool/libtool-2.4.2.tar.gz
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

cd $SRC
mkdir m4 && cd m4
$WGET http://ftp.gnu.org/gnu/m4/m4-1.4.16.tar.gz
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

cd $SRC
mkdir make && cd make
$WGET http://ftp.gnu.org/gnu/make/make-3.82.tar.gz
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

cd $SRC
mkdir util-linux && cd util-linux
$WGET http://www.kernel.org/pub/linux/utils/util-linux/v2.21/util-linux-2.21.2.tar.gz
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

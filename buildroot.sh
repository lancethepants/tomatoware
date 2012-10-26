#!/bin/sh

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
PATCHES=$BASE/patches
RPATH=/opt/lib
DEST=/opt
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 -Wl,--gc-sections -Wl,-rpath,$RPATH -Wl,-rpath-link=$RPATH"
CPPFLAGS="-I$DEST/include -I$DEST/include/ncurses"
CFLAGS="-DBCMWPA2 -funit-at-a-time -Wno-pointer-sign -mtune=mips32 -mips32"
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make"

mkdir -p $SRC

$WGET http://wl500g-repo.googlecode.com/files/entware-toolchain-r4667-amd64.tgz
tar zxvf entware-toolchain-r4667-amd64.tgz
mv opt/entware-toolchain/ ./toolchain
rm -rf opt/ entware-toolchain-r4667-amd64.tgz
export PATH=$PATH:$BASE/toolchain/bin:$BASE/toolchain/mipsel-linux/bin

cd $DEST
sudo rm -rf bin/ docs/ include/ lib/ libexec/ man/ sbin/ share/ mipsel-linux/
sudo mkdir bin docs include lib libexec man sbin share mipsel-linux
sudo chown lance:lance bin/ docs/ include/ lib/ libexec/ man/ sbin/ share/ mipsel-linux/

######## ####################################################################
# GLIB # ####################################################################
######## ####################################################################

cd $SRC
mkdir glib && cd glib
$WGET http://ftp.acc.umu.se/pub/gnome/sources/glib/2.35/glib-2.35.1.tar.xz
tar xvJf glib-2.35.1.tar.xz
cd glib-2.35.1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

########### #################################################################
# GETTEXT # #################################################################
########### #################################################################

cd $SRC
mkdir gettext && cd gettext
$WGET http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.1.1.tar.gz
tar zxvf gettext-0.18.1.1.tar.gz
cd gettext-0.18.1.1

patch -p1 < $PATCHES/spawn.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install

############## ##############################################################
# PKG-CONFIG # ##############################################################
############## ##############################################################

cd $SRC
mkdir pkg-config && cd pkg-config
$WGET http://pkgconfig.freedesktop.org/releases/pkg-config-0.27.tar.gz
tar zxvf pkg-config-0.27.tar.gz
cd pkg-config-0.27

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-internal-glib


######## ####################################################################
# PERL # ####################################################################
######## ####################################################################

cd $SRC
mkdir perl && cd perl
$WGET http://www.cpan.org/src/5.0/perl-5.16.0.tar.gz
tar zxvf perl-5.16.0.tar.gz
cp $PATCHES/perl-5.16.0-cross-0.7.tar.gz .
tar zxvf perl-5.16.0-cross-0.7.tar.gz
	
LDFLAGS="-Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH" \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
./configure --target=mipsel-linux --prefix=/opt

$MAKE
make install

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
--disable-werror

$MAKE
make install

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
make install

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
make install

####### #####################################################################
# MPC # #####################################################################
####### #####################################################################

cd $SRC
mkdir mpc && cd mpc
$WGET http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz
tar zxvf mpc-1.0.1.tar.gz
cd mpc-1.0.1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install

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
make install




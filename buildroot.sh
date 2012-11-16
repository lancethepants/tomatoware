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

if [ ! -d toolchain ]
then
$WGET http://wl500g-repo.googlecode.com/files/entware-toolchain-r4667-amd64.tgz
tar zxvf entware-toolchain-r4667-amd64.tgz
mv opt/entware-toolchain/ ./toolchain
rm -rf opt/ entware-toolchain-r4667-amd64.tgz
fi

export PATH=$PATH:$BASE/toolchain/bin:$BASE/toolchain/mipsel-linux/bin

sudo rm -rf /opt/bin/ /opt/docs/ /opt/etc/ /opt/include/ /opt/lib/ /opt/libexec/ /opt/man/ /opt/sbin/ /opt/share/ /opt/mipsel-linux/ /opt/var/
sudo mkdir /opt/bin /opt/docs /opt/etc /opt/include /opt/lib /opt/libexec /opt/man /opt/sbin /opt/share /opt/mipsel-linux /opt/var
sudo chown lance:lance /opt/bin/ /opt/etc /opt/docs/ /opt/include/ /opt/lib/ /opt/libexec/ /opt/man/ /opt/sbin/ /opt/share/ /opt/mipsel-linux/ /opt/var/

######### ###################################################################
# BZIP2 # ###################################################################
######### ###################################################################

cd $SRC
mkdir bzip2 && cd bzip2 
$WGET http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
tar zxvf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6

patch < $PATCHES/bzip2.patch
patch < $PATCHES/bzip2_so.patch

$MAKE
$MAKE -f Makefile-libbz2_so
make install PREFIX=$DEST


######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

cd $SRC
mkdir zlib && cd zlib
$WGET http://zlib.net/zlib-1.2.7.tar.gz
tar zxvf zlib-1.2.7.tar.gz
cd zlib-1.2.7

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CROSS_PREFIX=mipsel-linux- \
./configure \
--prefix=/opt 

$MAKE
make install

########## ##################################################################
# LIBFFI # ##################################################################
########## ##################################################################

cd $SRC
mkdir libffi && cd libffi
$WGET ftp://sourceware.org/pub/libffi/libffi-3.0.11.tar.gz
tar zxvf libffi-3.0.11.tar.gz
cd libffi-3.0.11

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

############ ################################################################
# LIBICONV # ################################################################
############ ################################################################

cd $SRC
mkdir libiconv && cd libiconv
$WGET http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install

######## ####################################################################
# GLIB # ####################################################################
######## ####################################################################

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
make install

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
$CONFIGURE 

$MAKE
make install

######## ####################################################################
# PERL # ####################################################################
######## ####################################################################

cd $SRC
mkdir perl && cd perl
$WGET http://www.cpan.org/src/5.0/perl-5.16.0.tar.gz
tar zxvf perl-5.16.0.tar.gz
cp $PATCHES/perl-5.16.0-cross-0.7.tar.gz .
tar zxvf perl-5.16.0-cross-0.7.tar.gz
cd perl-5.16.0
	
LDFLAGS="-Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH" \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
./configure --target=mipsel-linux --prefix=/opt

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
make install

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
make install

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
make install

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
make install

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
make install

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
make install

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
make install

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
make install

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
make install

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
make install

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
make install

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
make install


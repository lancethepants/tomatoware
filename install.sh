#!/bin/sh

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
PATCHES=$BASE/patches
RPATH=/opt/lib
DEST=$BASE/tomato
LDFLAGS="-L$DEST/lib -s -Wl,--gc-sections -Wl,-rpath,$RPATH -Wl,-rpath-link=$RPATH"
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
$CONFIGURE \
--bindir=$DEST/bin \
--sbindir=$DEST/sbin \
--libexecdir=$DEST/libexec \
--sysconfdir=$DEST/etc \
--sharedstatedir=$DEST/com \
--localstatedir=$DEST/var \
--libdir=$DEST/lib \
--includedir=$DEST/include \
--datarootdir=$DEST/share 

$MAKE
make install prefix=$DEST

########## ##################################################################
# SQLITE # ##################################################################
########## ##################################################################

cd $SRC
mkdir sqlite && cd sqlite
$WGET http://www.sqlite.org/sqlite-autoconf-3071400.tar.gz
tar zxvf sqlite-autoconf-3071400.tar.gz
cd sqlite-autoconf-3071400

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install prefix=$DEST

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
make install prefix=$DEST

####### #####################################################################
# LZO # #####################################################################
####### #####################################################################

cd $SRC
mkdir lzo && cd lzo
$WGET http://www.oberhumer.com/opensource/lzo/download/lzo-2.06.tar.gz
tar zxvf lzo-2.06.tar.gz
cd lzo-2.06

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-shared=yes 

$MAKE
make install prefix=$DEST

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

cd $SRC
mkdir openssl && cd openssl
$WGET http://www.openssl.org/source/openssl-1.0.1c.tar.gz
tar zxvf openssl-1.0.1c.tar.gz
cd openssl-1.0.1c

patch < $PATCHES/openssl.patch
#patch -p1 < ../../patches/110-optimize-for-size.patch
#patch -p1 < ../../patches/130-perl-path.patch
#patch -p1 < ../../patches/140-makefile-dirs.patch
#patch -p1 < ../../patches/150-no_engines.patch
#patch -p1 < ../../patches/160-disable_doc_tests.patch
#patch -p1 < ../../patches/170-bash_path.patch
#patch -p1 < ../../patches/180-fix_link_segfault.patch
#patch -p1 < ../../patches/190-remove_timestamp_check.patch
#patch -p1 < ../../patches/200-etrax_support.patch

./Configure linux-mipsel \
-ffunction-sections -fdata-sections \
-Wl,--gc-sections -Wl,-rpath,$RPATH -Wl,-rpath-link=$RPATH \
--prefix=/opt shared zlib-dynamic threads \
--with-zlib-include=$DEST/include \
--with-zlib-lib=$DEST/lib

$MAKE CC=mipsel-linux-gcc AR="mipsel-linux-ar r" RANLIB=mipsel-linux-ranlib
make install CC=mipsel-linux-gcc AR="mipsel-linux-ar r" RANLIB=mipsel-linux-ranlib INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl


########### #################################################################
# NCURSES # #################################################################
########### #################################################################

cd $SRC
mkdir ncurses && cd ncurses
$WGET http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz
tar zxvf ncurses-5.9.tar.gz
cd ncurses-5.9

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-normal \
--with-shared \
--enable-rpath 

$MAKE
make install prefix=$DEST

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################

cd $SRC
mkdir libreadline && cd libreadline
$WGET ftp://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz
tar zxvf readline-6.2.tar.gz
cd readline-6.2

patch < $PATCHES/readline.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install prefix=$DEST

########### #################################################################
# LIBGDBM # #################################################################
########### #################################################################

cd $SRC
mkdir libgdbm && cd libgdbm
$WGET ftp://ftp.gnu.org/gnu/gdbm/gdbm-1.10.tar.gz
tar zxvf gdbm-1.10.tar.gz
cd gdbm-1.10

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install prefix=$DEST

####### #####################################################################
# tcl # #####################################################################
####### #####################################################################

cd $SRC
mkdir tcl && cd tcl
$WGET http://downloads.sourceforge.net/project/tcl/Tcl/8.5.12/tcl8.5.12-src.tar.gz
tar zxvf tcl8.5.12-src.tar.gz
cd tcl8.5.12/unix

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-threads \
--enable-shared \
--enable-symbols \
ac_cv_func_strtod=yes \
tcl_cv_strtod_buggy=1

patch < $PATCHES/tcl.patch

$MAKE
make install prefix=$DEST exec_prefix=$DEST libdir=$DEST/lib includedir=$DEST/include

######### ###################################################################
# bsdbm # ###################################################################
######### ###################################################################

cd $SRC
mkdir bsdbm && cd bsdbm
$WGET http://download.oracle.com/berkeley-db/db-4.7.25.tar.gz
tar zxvf db-4.7.25.tar.gz
cd  db-4.7.25/build_unix

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
../dist/$CONFIGURE \
--enable-tcl \
--with-tcl=$DEST/lib

$MAKE
make install prefix=$DEST

########## ##################################################################
# PYTHON # ##################################################################
########## ##################################################################

cd $SRC
mkdir python && cd python
$WGET http://python.org/ftp/python/2.7.3/Python-2.7.3.tgz
tar zxvf Python-2.7.3.tgz
cp -r Python-2.7.3 Python-2.7.3-native

cd Python-2.7.3-native
./configure
$MAKE

cd ../Python-2.7.3
$WGET http://www.droboports.com/app-repository/python-2-7-3/drobofs.patch
patch < drobofs.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CC=mipsel-linux-gcc CXX=mipsel-linux-g++ AR=mipsel-linux-ar RANLIB=mipsel-linux-ranlib \
$CONFIGURE --build=x86_64-linux-gnu --with-dbmliborder=gdbm:bdb --with-threads --with-system-ffi

cp ../Python-2.7.3-native/python ./hostpython
cp ../Python-2.7.3-native/Parser/pgen Parser/hostpgen

$MAKE HOSTPYTHON=./hostpython HOSTPGEN=./Parser/hostpgen CROSS_COMPILE=mipsel-linux- CROSS_COMPILE_TARGET=yes HOSTARCH=mipsel-linux BUILDARCH=x86_64-linux-gnu
make install prefix=$DEST HOSTPYTHON=../Python-2.7.3-native/python CROSS_COMPILE=mipsel-linux- CROSS_COMPILE_TARGET=yes

############ ################################################################
# POLARSSL # ################################################################
############ ################################################################

cd $SRC
mkdir polarssl && cd polarssl
$WGET http://polarssl.org/code/releases/polarssl-1.1.4-gpl.tgz
tar zxvf polarssl-1.1.4-gpl.tgz
cd polarssl-1.1.4

patch < $PATCHES/polarssl.patch
cd library
patch < $PATCHES/polarssl_lib.patch
cd ..

$MAKE
make install DESTDIR=$DEST
ln -s libpolarssl.so $DEST/lib/libpolarssl.so.0

########### #################################################################
# LIBPCAP # #################################################################
########### #################################################################

cd $SRC
mkdir libpcap && cd libpcap
$WGET http://www.tcpdump.org/release/libpcap-1.3.0.tar.gz
tar zxvf libpcap-1.3.0.tar.gz
cd libpcap-1.3.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-pcap=linux \
--enable-ipv6

$MAKE
make install prefix=$DEST

########### #################################################################
# OPENVPN # #################################################################
########### #################################################################

cd $SRC
mkdir openvpn && cd openvpn
$WGET http://swupdate.openvpn.org/community/releases/openvpn-2.3_beta1.tar.gz
tar zxvf openvpn-2.3_beta1.tar.gz
cd openvpn-2.3_beta1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-crypto-library=polarssl \
--disable-plugin-auth-pam

$MAKE
make install prefix=$DEST

######## ####################################################################
# TINC # ####################################################################
######## ####################################################################

cd $SRC
mkdir tinc && cd tinc
$WGET http://www.tinc-vpn.org/packages/tinc-1.0.19.tar.gz
tar zxvf tinc-1.0.19.tar.gz
cd tinc-1.0.19

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install prefix=$DEST

############## ##############################################################
# SETUPTOOLS # ##############################################################
############## ##############################################################

cd $SRC
mkdir setuptools && cd setuptools
$WGET http://pypi.python.org/packages/source/s/setuptools/setuptools-0.6c11.tar.gz
tar zxvf setuptools-0.6c11.tar.gz

########### #################################################################
# CHEETAH # #################################################################
########### #################################################################

cd $SRC/python/Python-2.7.3/build/
mv lib.linux-x86_64-2.7/ lib.linux-mipsel-2.7/
cp -R ../../Python-2.7.3-native/build/lib.linux-x86_64-2.7/ .

cd $SRC
mkdir cheetah && cd cheetah
$WGET http://pypi.python.org/packages/source/C/Cheetah/Cheetah-2.4.4.tar.gz
tar zxvf Cheetah-2.4.4.tar.gz
cd Cheetah-2.4.4
PYTHONPATH=../../python/Python-2.7.3/Lib/:../../setuptools/setuptools-0.6c11 ../../python/Python-2.7.3/hostpython ./setup.py bdist_egg
mv dist/Cheetah-2.4.4-py2.7-linux-x86_64.egg dist/Cheetah-2.4.4-py2.7.egg

mkdir -p $DEST/python_modules
cp dist/Cheetah-2.4.4-py2.7.egg $DEST/python_modules

cd $SRC/python/Python-2.7.3/build/
rm -rf lib.linux-x86_64-2.7/
mv lib.linux-mipsel-2.7/ lib.linux-x86_64-2.7/

######## ####################################################################
# YENC # ####################################################################
######## ####################################################################

cd $SRC/python/Python-2.7.3/build/
mv lib.linux-x86_64-2.7/ lib.linux-mipsel-2.7/
cp -R ../../Python-2.7.3-native/build/lib.linux-x86_64-2.7/ .

cd $SRC
mkdir yenc && cd yenc
$WGET http://www.golug.it/pub/yenc/yenc-0.4.0.tar.gz
tar zxvf yenc-0.4.0.tar.gz
cd yenc-0.4.0

patch < $PATCHES/yenc.patch
PYTHONPATH=../../python/Python-2.7.3/Lib/:../../setuptools/setuptools-0.6c11 ../../python/Python-2.7.3/hostpython ./setup.py bdist_egg
mv dist/yenc-0.4.0-py2.7-linux-x86_64.egg dist/yenc-0.4.0-py2.7.egg
mkdir -p $DEST/python_modules
cp dist/yenc-0.4.0-py2.7.egg $DEST/python_modules

cd $SRC/python/Python-2.7.3/build/
rm -rf lib.linux-x86_64-2.7/
mv lib.linux-mipsel-2.7/ lib.linux-x86_64-2.7/

############### #############################################################
# PAR2CMDLINE # #############################################################
############### #############################################################

cd $SRC
mkdir par2cmdline && cd par2cmdline
$WGET http://downloads.sourceforge.net/project/parchive/par2cmdline/0.4/par2cmdline-0.4.tar.gz
tar zxvf par2cmdline-0.4.tar.gz
cd par2cmdline-0.4

patch reedsolomon.cpp $PATCHES/reedsolomon.cpp.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

make clean 
$MAKE
make install prefix=$DEST

######### ###################################################################
# UNRAR # ###################################################################
######### ###################################################################

cd $SRC
mkdir unrar && cd unrar
$WGET http://www.rarlab.com/rar/unrarsrc-4.2.4.tar.gz
tar zxvf unrarsrc-4.2.4.tar.gz
cd unrar

mv makefile.unix Makefile
patch < $PATCHES/unrar.patch

$MAKE CXX=mipsel-linux-g++ CXXFLAGS=$CPPFLAGS STRIP=mipsel-linux-strip
make install DESTDIR=$DEST

############# ###############################################################
# pyOpenSSL # ###############################################################
############# ###############################################################

cd $SRC/python/Python-2.7.3/build/
mv lib.linux-x86_64-2.7/ lib.linux-mipsel-2.7/
cp -R ../../Python-2.7.3-native/build/lib.linux-x86_64-2.7/ .

cd $SRC
mkdir pyopenssl && cd pyopenssl
$WGET http://pypi.python.org/packages/source/p/pyOpenSSL/pyOpenSSL-0.13.tar.gz
tar zxvf pyOpenSSL-0.13.tar.gz
cd pyOpenSSL-0.13

PYTHONPATH=../../python/Python-2.7.3/Lib/ ../../python/Python-2.7.3/hostpython setup.py build_ext -I$DEST/include -L$DEST/lib -R$RPATH
sed -i -e "s|from distutils.core import Extension, setup|from setuptools import setup\nfrom distutils.core import Extension|g" setup.py
PYTHONPATH=../../python/Python-2.7.3/Lib/:../../setuptools/setuptools-0.6c11 ../../python/Python-2.7.3/hostpython setup.py bdist_egg
mv dist/pyOpenSSL-0.13-py2.7-linux-x86_64.egg dist/pyOpenSSL-0.13-py2.7.egg

mkdir -p $DEST/python_modules
cp dist/pyOpenSSL-0.13-py2.7.egg $DEST/python_modules

cd $SRC/python/Python-2.7.3/build/
rm -rf lib.linux-x86_64-2.7/
mv lib.linux-mipsel-2.7/ lib.linux-x86_64-2.7/

######### ###################################################################
# UCARP # ###################################################################
######### ###################################################################

cd $SRC
mkdir ucarp && cd ucarp
$WGET http://download.pureftpd.org/pub/ucarp/ucarp-1.5.2.tar.gz
tar zxvf ucarp-1.5.2.tar.gz
cd ucarp-1.5.2

patch < $PATCHES/ucarp.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install prefix=$DEST

############ ################################################################
# DNSCRYPT # ################################################################
############ ################################################################

cd $SRC
mkdir dnscrypt && cd dnscrypt
$WGET https://github.com/downloads/opendns/dnscrypt-proxy/dnscrypt-proxy-1.1.0.tar.gz
tar zxvf dnscrypt-proxy-1.1.0.tar.gz
cd dnscrypt-proxy-1.1.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-plugins

$MAKE
make install prefix=$DEST

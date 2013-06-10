#!/bin/bash

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
PATCHES=$BASE/patches
RPATH=/opt/lib
DEST=$BASE/opt
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
CPPFLAGS="-I$DEST/include -I$DEST/include/ncurses"
CFLAGS="-mtune=mips32 -mips32"
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make -j`nproc`"
echo "`nproc` CPU(S) detected"
echo "Will use parallel building if available"
sleep 5 

mkdir -p $SRC

export PATH=$PATH:/opt/entware-toolchain/bin/:/opt/entware-toolchain/mipsel-linux/bin/

######### ###################################################################
# BZIP2 # ###################################################################
######### ###################################################################

cd $SRC/bzip2
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

cd $SRC/zlib
tar zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CROSS_PREFIX=mipsel-linux- \
./configure \
--prefix=/opt 

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# LZO # #####################################################################
####### #####################################################################

cd $SRC/lzo
tar zxvf lzo-2.06.tar.gz
cd lzo-2.06

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-shared=yes 

$MAKE
make install DESTDIR=$BASE

############ ################################################################
# POLARSSL # ################################################################
############ ################################################################

cd $SRC/polarssl
tar zxvf polarssl-1.2.7-gpl.tgz
cd polarssl-1.2.7

patch < $PATCHES/polarssl.patch
cd library
patch < $PATCHES/polarssl_lib.patch
cd ..

$MAKE
make install DESTDIR=$DEST
ln -s libpolarssl.so $DEST/lib/libpolarssl.so.0

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

cd $SRC/openssl
tar zxvf openssl-1.0.1e.tar.gz
cd openssl-1.0.1e

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
-Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 \
-Wl,--gc-sections -Wl,-rpath,$RPATH -Wl,-rpath-link=$RPATH \
--prefix=/opt shared no-zlib no-zlib-dynamic

make CC=mipsel-linux-gcc AR="mipsel-linux-ar r" RANLIB=mipsel-linux-ranlib
make install CC=mipsel-linux-gcc AR="mipsel-linux-ar r" RANLIB=mipsel-linux-ranlib INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl

########### #################################################################
# GETTEXT # #################################################################
########### #################################################################

cd $SRC/gettext
tar zxvf gettext-0.18.2.tar.gz
cd gettext-0.18.2

patch -p1 < $PATCHES/spawn.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# CURL # ####################################################################
######## ####################################################################

cd $SRC/curl
tar curl-7.30.0.tar.gz
cd curl-7.30.0

patch < $PATCHES/curl.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-ca-path=/opt/ssl/certs

$MAKE
make install DESTDIR=$BASE

mkdir -p $DEST/ssl/certs
cd $DEST/ssl/certs
curl http://curl.haxx.se/ca/cacert.pem | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}'
c_rehash .

######### ###################################################################
# EXPAT # ###################################################################
######### ###################################################################

cd $SRC/expat
tar zxvf expat-2.1.0.tar.gz
cd expat-2.1.0

LDFLAGS=$LDFLAGS  \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# LIBPCAP # #################################################################
########### #################################################################

cd $SRC/libpcap
tar zxvf libpcap-1.4.0.tar.gz
cd libpcap-1.4.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-pcap=linux \
--enable-ipv6

$MAKE
make install DESTDIR=$BASE

########## ##################################################################
# LIBFFI # ##################################################################
########## ##################################################################

cd $SRC/libffi
tar zxvf libffi-3.0.13.tar.gz
cd libffi-3.0.13

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

############ ################################################################
# LIBICONV # ################################################################
############ ################################################################

cd $SRC/libiconv
tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# NCURSES # #################################################################
########### #################################################################

cd $SRC/ncurses
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
make install DESTDIR=$BASE

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################

cd $SRC/libreadline
tar zxvf readline-6.2.tar.gz
cd readline-6.2

patch < $PATCHES/readline.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# LIBGDBM # #################################################################
########### #################################################################

cd $SRC/libgdbm
tar zxvf gdbm-1.10.tar.gz
cd gdbm-1.10

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# tcl # #####################################################################
####### #####################################################################

cd $SRC/tcl
tar zxvf tcl8.6.0-src.tar.gz
cd tcl8.6.0/unix

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-threads \
--enable-shared \
--enable-symbols \
ac_cv_func_strtod=yes \
tcl_cv_strtod_buggy=1

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# bdb # #####################################################################
####### #####################################################################

cd $SRC/bdb
tar zxvf db-4.7.25.tar.gz
cd  db-4.7.25/build_unix

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
../dist/$CONFIGURE \
--enable-tcl \
--with-tcl=$DEST/lib

$MAKE
make install DESTDIR=$BASE

########## ##################################################################
# SQLITE # ##################################################################
########## ##################################################################

cd $SRC/sqlite
tar zxvf sqlite-autoconf-3071700.tar.gz
cd sqlite-autoconf-3071700

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########## ##################################################################
# LIBXML # ##################################################################
########## ##################################################################

cd $SRC/libxml2
tar zxvf libxml2-2.9.1.tar.gz
cd libxml2-2.9.1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# LIBXSLT # #################################################################
########### #################################################################

sed -i 's,\/opt\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
$DEST/lib/libxml2.la

cd $SRC/libxslt
tar zxvf libxslt-1.1.28.tar.gz
cd libxslt-1.1.28

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-libxml-src=$SRC/libxml2/libxml2-2.9.0 \
--without-python \
--without-crypto

$MAKE
make install DESTDIR=$BASE

sed -i 's,'"$DEST"'\/lib\/libiconv.la,\/opt\/lib\/libiconv.la,g' \
$DEST/lib/libxml2.la

############# ###############################################################
# LIBSIGC++ # ###############################################################
############# ###############################################################

cd $SRC/libsigc++
tar xvJf libsigc++-2.3.1.tar.xz
cd libsigc++-2.3.1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

patch < $PATCHES/libsigc++/libsigc++.patch

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# LIBPAR2 # #################################################################
########### #################################################################

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/libpar2
tar zxvf libpar2-0.2.tar.gz
cd libpar2-0.2

LDFLAGS=$LDFLAGS \
CPPFLAGS="$CPPFLAGS -I$DEST/include/sigc++-2.0 -I$DEST/lib/sigc++-2.0/include" \
CFLAGS=$CFLAGS \
$CONFIGURE 

$MAKE
make install DESTDIR=$BASE

unset PKG_CONFIG_LIBDIR

############ ################################################################
# LIBEVENT # ################################################################
############ ################################################################

cd $SRC/libevent
tar zxvf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# PERL # ####################################################################
######## ####################################################################

cd $SRC/perl
tar zxvf perl_precompiled.tgz -C $BASE

#tar zxvf perl-5.16.0.tar.gz
#cp $PATCHES/perl-5.16.0-cross-0.7.1.tar.gz .
#tar zxvf perl-5.16.0-cross-0.7.1.tar.gz
#cd perl-5.16.0

#LDFLAGS="-Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH" \
#CPPFLAGS=$CPPFLAGS \
#CFLAGS=$CFLAGS \
#./configure --target=mipsel-linux --prefix=/opt -Dusethreads

#make
#make install DESTDIR=$BASE

######## ####################################################################
# PCRE # ####################################################################
######## ####################################################################

cd $SRC/pcre
tar zxvf pcre-8.33.tar.gz
cd pcre-8.33

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-pcregrep-libz \
--enable-pcregrep-libbz2 \
--enable-pcretest-libreadline

$MAKE
make install DESTDIR=$BASE

########## ##################################################################
# PYTHON # ##################################################################
########## ##################################################################

cd $SRC/python
tar zxvf Python-2.7.3.tgz
cp -r Python-2.7.3 Python-2.7.3-native

cd Python-2.7.3-native
./configure
$MAKE

cd ../Python-2.7.3
patch < $PATCHES/python-drobo.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CC=mipsel-linux-gcc CXX=mipsel-linux-g++ AR=mipsel-linux-ar RANLIB=mipsel-linux-ranlib \
$CONFIGURE --build=x86_64-linux-gnu --with-dbmliborder=gdbm:bdb --with-threads --with-system-ffi

cp ../Python-2.7.3-native/python ./hostpython
cp ../Python-2.7.3-native/Parser/pgen Parser/hostpgen

$MAKE HOSTPYTHON=./hostpython HOSTPGEN=./Parser/hostpgen CROSS_COMPILE=mipsel-linux- CROSS_COMPILE_TARGET=yes HOSTARCH=mipsel-linux BUILDARCH=x86_64-linux-gnu
make install DESTDIR=$BASE HOSTPYTHON=../Python-2.7.3-native/python CROSS_COMPILE=mipsel-linux- CROSS_COMPILE_TARGET=yes

############## ##############################################################
# SETUPTOOLS # ##############################################################
############## ##############################################################

cd $SRC/setuptools
tar zxvf setuptools-0.6c11.tar.gz

########### #################################################################
# CHEETAH # #################################################################
########### #################################################################

cd $SRC/python/Python-2.7.3/build/
mv lib.linux-x86_64-2.7/ lib.linux-mipsel-2.7/
cp -R ../../Python-2.7.3-native/build/lib.linux-x86_64-2.7/ .

cd $SRC/cheetah
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

cd $SRC/yenc
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

############# ###############################################################
# pyOpenSSL # ###############################################################
############# ###############################################################

cd $SRC/python/Python-2.7.3/build/
mv lib.linux-x86_64-2.7/ lib.linux-mipsel-2.7/
cp -R ../../Python-2.7.3-native/build/lib.linux-x86_64-2.7/ .

cd $SRC/pyopenssl
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

############### #############################################################
# PAR2CMDLINE # #############################################################
############### #############################################################

cd $SRC/par2cmdline
tar zxvf par2cmdline-0.4.tar.gz
cd par2cmdline-0.4

patch reedsolomon.cpp $PATCHES/reedsolomon.cpp.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

make clean 
$MAKE
make install DESTDIR=$BASE

######### ###################################################################
# UNRAR # ###################################################################
######### ###################################################################

cd $SRC/unrar
tar zxvf unrarsrc-4.2.4.tar.gz
cd unrar

mv makefile.unix Makefile
patch < $PATCHES/unrar.patch

$MAKE CXX=mipsel-linux-g++ CXXFLAGS=$CPPFLAGS STRIP=mipsel-linux-strip
make install DESTDIR=$DEST

######### ###################################################################
# UCARP # ###################################################################
######### ###################################################################

cd $SRC/ucarp
tar zxvf ucarp-1.5.2.tar.gz
cd ucarp-1.5.2

patch < $PATCHES/ucarp.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENVPN # #################################################################
########### #################################################################

cd $SRC/openvpn
tar zxvf openvpn-2.3.2.tar.gz
cd openvpn-2.3.2

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-crypto-library=polarssl \
--disable-plugin-auth-pam

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# TINC # ####################################################################
######## ####################################################################

cd $SRC/tinc
tar zxvf tinc-1.0.20.tar.gz
cd tinc-1.0.20

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

############ ################################################################
# DNSCRYPT # ################################################################
############ ################################################################

cd $SRC/dnscrypt
tar zxvf dnscrypt-proxy-1.2.0.tar.gz
cd dnscrypt-proxy-1.2.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

####### #####################################################################
# GIT # #####################################################################
####### #####################################################################

cd $SRC/git
tar zxvf v1.8.1.1.tar.gz
cd git-1.8.1.1

make distclean

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$MAKE \
CC=mipsel-linux-gcc \
AR=mipsel-linux-ar \
prefix=/opt \
FREAD_READS_DIRECTORIES=no \
SNPRINTF_RETURNS_BOGUS=no \
NO_TCLTK=yes \
NO_R_TO_GCC_LINKER=yes \
NO_GETTEXT=yes \
NO_ICONV=yes \
EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -pthread"

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
make \
CC=mipsel-linux-gcc \
AR=mipsel-linux-ar \
prefix=/opt \
FREAD_READS_DIRECTORIES=no \
SNPRINTF_RETURNS_BOGUS=no \
NO_TCLTK=yes \
NO_R_TO_GCC_LINKER=yes \
NO_GETTEXT=yes \
NO_ICONV=yes \
EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -pthread" \
install DESTDIR=$BASE

########## ##################################################################
# STRACE # ##################################################################
########## ##################################################################

cd $SRC/strace
tar xvJf strace-4.7.tar.xz
cd strace-4.7

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENSSH # #################################################################
########### #################################################################

cd $SRC/openssh
tar zxvf openssh-6.1p1.tar.gz
cd openssh-6.1p1

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-pid-dir=/var/run \
--with-privsep-path=/var/empty \
--disable-strip

patch < $PATCHES/openssh.patch

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# HTOP # ####################################################################
######## ####################################################################

cd $SRC/htop
tar zxvf htop-1.0.2.tar.gz
cd htop-1.0.2

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--disable-unicode

$MAKE
make install DESTDIR=$BASE

########## ##################################################################
# SCREEN # ##################################################################
########## ##################################################################

cd $SRC/screen
tar zxvf screen-4.0.3.tar.gz
cd screen-4.0.3

patch < $PATCHES/100-cross_compile_fix.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# BASH # ####################################################################
######## ####################################################################

cd $SRC/bash
tar zxvf bash-4.2.tar.gz
cd bash-4.2

patch < $PATCHES/bash/001-compile-fix.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-installed-readline

$MAKE
make install DESTDIR=$BASE

########## ##################################################################
# NZBGET # ##################################################################
########## ##################################################################

cd $SRC/nzbget
tar zxvf nzbget-9.0.tar.gz
cd nzbget-9.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--with-libxml2-includes=$DEST/include/libxml2 \
--with-libxml2-libraries=$DEST/lib \
--with-libcurses-includes=$DEST/include \
--with-libcurses-libraries=$DEST/lib \
--with-libsigc-includes=$DEST/include/sigc++-2.0/ \
--with-libsigc-libraries=$DEST/lib \
--with-libpar2-includes=$DEST/include \
--with-libpar2-libraries=$DEST/lib \
--with-tlslib=OpenSSL \
--with-openssl-includes=$DEST/include \
--with-openssl-libraries=$DEST/lib \
--with-zlib-includes=$DEST/include \
--with-zlib-libraries=$DEST/lib

$MAKE
make install DESTDIR=$BASE

################ ############################################################
# TRANSMISSION # ############################################################
################ ############################################################

cd $SRC/transmission
tar xvJf transmission-2.76.tar.xz
cd transmission-2.76

LIBEVENT_CFLAGS="-I$DEST/include -I$DEST/include/ncurses" \
LIBEVENT_LIBS=$DEST/lib/libevent.la \
LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
$CONFIGURE \
--enable-lightweight

$MAKE CFLAGS=-liconv
make install DESTDIR=$BASE

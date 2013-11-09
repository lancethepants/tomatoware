#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=$BASE/src
PATCHES=$BASE/patches
RPATH=$PREFIX/lib
DEST=$BASE$PREFIX
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
CPPFLAGS="-I$DEST/include -I$DEST/include/ncurses"
CFLAGS="-mtune=mips32 -mips32"
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=$PREFIX --host=mipsel-linux"
MAKE="make -j`nproc`"

######### ###################################################################
# BZIP2 # ###################################################################
######### ###################################################################

cd $SRC/bzip2

if [ ! -f .extracted ]; then
	rm -rf bzip2-1.0.6 
	tar zxvf bzip2-1.0.6.tar.gz
	touch .extracted
fi

cd bzip2-1.0.6

if [ ! -f .patched ]; then
	patch < $PATCHES/bzip2.patch
	patch < $PATCHES/bzip2_so.patch
	touch .patched
fi

if [ ! -f .built ]; then
	$MAKE
	$MAKE -f Makefile-libbz2_so
	touch .built
fi

if [ ! -f .installed ]; then
	make install PREFIX=$DEST
	touch .installed
fi


######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

cd $SRC/zlib

if [ ! -f .extracted ]; then
	rm -rf zlib-1.2.8
	tar zxvf zlib-1.2.8.tar.gz
	touch .extracted
fi

cd zlib-1.2.8

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	CROSS_PREFIX=mipsel-linux- \
	./configure \
	--prefix=$PREFIX
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
# LZO # #####################################################################
####### #####################################################################

cd $SRC/lzo

if [ ! -f .extracted ]; then
	rm -rf lzo-2.06
	tar zxvf lzo-2.06.tar.gz
	touch .extracted
fi

cd lzo-2.06

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-shared=yes 
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
# XZ UTILS # ################################################################
############ ################################################################

cd $SRC/xz

if [ ! -f .extracted ]; then
        rm -rf xz-5.0.5
        tar zxvf xz-5.0.5.tar.gz
        touch .extracted
fi

cd xz-5.0.5

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
# OPENSSL # #################################################################
########### #################################################################

cd $SRC/openssl

if [ ! -f .extracted ]; then
	rm -rf openssl-1.0.1e
	tar zxvf openssl-1.0.1e.tar.gz
	touch .extracted
fi

cd openssl-1.0.1e

if [ ! -f .configured ]; then
	./Configure linux-mipsel \
	-Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.0 \
	-Wl,-rpath,$RPATH -Wl,-rpath-link=$RPATH \
	--prefix=$PREFIX shared no-zlib no-zlib-dynamic
	touch .configured
fi

if [ ! -f .built ]; then
	make CC=mipsel-linux-gcc AR="mipsel-linux-ar r" RANLIB=mipsel-linux-ranlib
	touch .built
fi

if [ ! -f .installed ]; then
	make install CC=mipsel-linux-gcc AR="mipsel-linux-ar r" RANLIB=mipsel-linux-ranlib INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl
	touch .installed
fi

########### #################################################################
# GETTEXT # #################################################################
########### #################################################################

cd $SRC/gettext

if [ ! -f .extracted ]; then
	rm -rf gettext-0.18.3.1
	tar zxvf gettext-0.18.3.1.tar.gz
	touch .extracted
fi

cd gettext-0.18.3.1

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/spawn.patch
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
# CURL # ####################################################################
######## ####################################################################

cd $SRC/curl

if [ ! -f .extracted ]; then
	rm -rf curl-7.33.0
	tar zxvf curl-7.33.0.tar.gz
	touch .extracted
fi

cd curl-7.33.0

if [ ! -f .patched ]; then
	patch < $PATCHES/curl.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-ca-path=$PREFIX/ssl/certs
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

if [ ! -f .certs_installed ]; then
	mkdir -p $DEST/ssl/certs
	cd $DEST/ssl/certs
	curl http://curl.haxx.se/ca/cacert.pem | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}'
	c_rehash .
	touch $SRC/curl/curl-7.33.0/.certs_installed
fi

######### ###################################################################
# EXPAT # ###################################################################
######### ###################################################################

cd $SRC/expat

if [ ! -f .extracted ]; then
	rm -rf cd expat-2.1.0
	tar zxvf expat-2.1.0.tar.gz
	touch .extracted
fi

cd expat-2.1.0

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS  \
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
# LIBPCAP # #################################################################
########### #################################################################

cd $SRC/libpcap

if [ ! -f .extracted ]; then
	rm -rf libpcap-1.4.0
	tar zxvf libpcap-1.4.0.tar.gz
	touch .extracted
fi

cd libpcap-1.4.0

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-pcap=linux \
	--enable-ipv6
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

########## ##################################################################
# LIBFFI # ##################################################################
########## ##################################################################

cd $SRC/libffi

if [ ! -f .extracted ]; then
	rm -rf libffi-3.0.13
	tar zxvf libffi-3.0.13.tar.gz
	touch .extracted
fi

cd libffi-3.0.13

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
# LIBICONV # ################################################################
############ ################################################################

cd $SRC/libiconv

if [ ! -f .extracted ]; then
	rm -rf libiconv-1.14
	tar zxvf libiconv-1.14.tar.gz
	touch .extracted
fi

cd libiconv-1.14

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-static
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
# NCURSES # #################################################################
########### #################################################################

cd $SRC/ncurses

if [ ! -f .extracted ]; then
	rm -rf ncurses-5.9
	tar zxvf ncurses-5.9.tar.gz
	touch .extracted
fi

cd ncurses-5.9

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-normal \
	--with-shared \
	--enable-rpath \
	--with-fallbacks=xterm
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

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################

cd $SRC/libreadline

if [ ! -f .extracted ]; then
	rm -rf readline-6.2
	tar zxvf readline-6.2.tar.gz
	touch .extracted
fi

cd readline-6.2

if [ ! -f .patched ]; then
	patch < $PATCHES/readline.patch
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

########### #################################################################
# LIBGDBM # #################################################################
########### #################################################################

cd $SRC/libgdbm

if [ ! -f .extracted ]; then
	rm -rf gdbm-1.10
	tar zxvf gdbm-1.10.tar.gz
	touch .extracted
fi

cd gdbm-1.10

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
# tcl # #####################################################################
####### #####################################################################

cd $SRC/tcl

if [ ! -f .extracted ]; then
	rm -rf cd tcl8.6.1/unix
	tar zxvf tcl8.6.1-src.tar.gz
	touch .extracted
fi

cd tcl8.6.1/unix

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-threads \
	--enable-shared \
	--enable-symbols \
	ac_cv_func_strtod=yes \
	tcl_cv_strtod_buggy=1
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
# bdb # #####################################################################
####### #####################################################################

cd $SRC/bdb

if [ ! -f .extracted ]; then
	rm -rf db-4.7.25
	tar zxvf db-4.7.25.tar.gz
	touch .extracted
fi

cd  db-4.7.25/build_unix

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	../dist/$CONFIGURE \
	--enable-tcl \
	--with-tcl=$DEST/lib
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

########## ##################################################################
# SQLITE # ##################################################################
########## ##################################################################

cd $SRC/sqlite

if [ ! -f .extracted ]; then
	rm -rf sqlite-autoconf-3080100
	tar zxvf sqlite-autoconf-3080100.tar.gz
	touch .extracted
fi

cd sqlite-autoconf-3080100

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

########## ##################################################################
# LIBXML # ##################################################################
########## ##################################################################

cd $SRC/libxml2

if [ ! -f .extracted ]; then
	rm -rf libxml2-2.9.1
	tar zxvf libxml2-2.9.1.tar.gz
	touch .extracted
fi

cd libxml2-2.9.1

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-python
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
# LIBXSLT # #################################################################
########### #################################################################

cd $SRC/libxslt

if [ ! -f .extracted ]; then
	rm -rf libxslt-1.1.28
	tar zxvf libxslt-1.1.28.tar.gz
	touch .extracted
fi

cd libxslt-1.1.28

if [ ! -f .edit_sed ]; then
	sed -i 's,'"$PREFIX"'\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
	$DEST/lib/libxml2.la
	touch .edit_sed
fi

if [ ! -f .edit_sed2 ]; then
	sed -i 's,'"$PREFIX"'\/lib\/liblzma.la,'"$DEST"'\/lib\/liblzma.la,g' \
	$DEST/lib/libxml2.la
	touch .edit_sed2
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-libxml-src=$SRC/libxml2/libxml2-2.9.1 \
	--without-python \
	--without-crypto
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
# LIBSIGC++ # ###############################################################
############# ###############################################################

cd $SRC/libsigc++

if [ ! -f .extracted ]; then
	rm -rf libsigc++-2.3.1
	tar xvJf libsigc++-2.3.1.tar.xz
	touch .extracted
fi

cd libsigc++-2.3.1

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-static
	touch .configured
fi

if [ ! -f .patched ]; then
	patch < $PATCHES/libsigc++/libsigc++.patch
	touch .patched
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
# LIBPAR2 # #################################################################
########### #################################################################

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/libpar2

if [ ! -f .extracted ]; then
	rm -rf libpar2-0.4
	tar zxvf libpar2-0.4.tar.gz
	touch .extracted
fi

cd libpar2-0.4

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS -I$DEST/include/sigc++-2.0 -I$DEST/lib/sigc++-2.0/include" \
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

unset PKG_CONFIG_LIBDIR

############ ################################################################
# LIBEVENT # ################################################################
############ ################################################################

cd $SRC/libevent

if [ ! -f .extracted ]; then
	rm -rf libevent-2.0.21-stable
	tar zxvf libevent-2.0.21-stable.tar.gz
	touch .extracted
fi

cd libevent-2.0.21-stable

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
# PERL # ####################################################################
######## ####################################################################

cd $SRC/perl

if [ ! -f .extracted ]; then
	rm -rf tar zxvf perl-5.18.1
	tar zxvf perl-5.18.1.tar.gz
	tar zxvf perl-5.18.1-cross-0.8.3.tar.gz
	touch .extracted
fi

cd perl-5.18.1/

if [ ! -f .configured ]; then
	LDFLAGS="-Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure \
	--prefix=$PREFIX \
	--target=mipsel-linux
	touch .configured
fi

if [ ! -f .built ]; then
	make
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# PCRE # ####################################################################
######## ####################################################################

cd $SRC/pcre

if [ ! -f .extracted ]; then
	rm -rf pcre-8.33
	tar zxvf pcre-8.33.tar.gz
	touch .extracted
fi

cd pcre-8.33

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-pcregrep-libz \
	--enable-pcregrep-libbz2 \
	--enable-pcretest-libreadline
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

########## ##################################################################
# PYTHON # ##################################################################
########## ##################################################################

cd $SRC/python

if [ ! -f .extracted ]; then
	rm -rf Python-2.7.3 Python-2.7.3-native
	tar zxvf Python-2.7.3.tgz
	cp -r Python-2.7.3 Python-2.7.3-native
	touch .extracted
fi

cd Python-2.7.3-native

if [ ! -f .built_native ]; then
	./configure
	$MAKE
	touch .built_native
fi

cd ../Python-2.7.3

if [ ! -f .patched ]; then
	patch < $PATCHES/python-drobo.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	CC=mipsel-linux-gcc CXX=mipsel-linux-g++ AR=mipsel-linux-ar RANLIB=mipsel-linux-ranlib \
	$CONFIGURE --build=x86_64-linux-gnu --with-dbmliborder=gdbm:bdb --with-threads --with-system-ffi
	touch .configured
fi

if [ ! -f .copied ]; then
	cp ../Python-2.7.3-native/python ./hostpython
	cp ../Python-2.7.3-native/Parser/pgen Parser/hostpgen
	touch .copied
fi

if [ ! -f .built ]; then
	$MAKE HOSTPYTHON=./hostpython HOSTPGEN=./Parser/hostpgen CROSS_COMPILE=mipsel-linux- CROSS_COMPILE_TARGET=yes HOSTARCH=mipsel-linux BUILDARCH=x86_64-linux-gnu
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE HOSTPYTHON=../Python-2.7.3-native/python CROSS_COMPILE=mipsel-linux- CROSS_COMPILE_TARGET=yes
	touch .installed
fi

if [ ! -f .mkdir ]; then
	mkdir -p $DEST/python_modules
	touch .mkdir
fi

cd $SRC/python/Python-2.7.3/build/

if [ ! -f .rename_and_move ]; then
	mv lib.linux-x86_64-2.7/ lib.linux-mipsel-2.7/
	cp -R ../../Python-2.7.3-native/build/lib.linux-x86_64-2.7/ .
	touch .rename_and_move
fi

############## ##############################################################
# SETUPTOOLS # ##############################################################
############## ##############################################################

cd $SRC/setuptools

if [ ! -f .extracted ]; then
	rm -rf setuptools-1.3.1
	tar zxvf setuptools-1.3.1.tar.gz
	touch .extracted
fi

########### #################################################################
# CHEETAH # #################################################################
########### #################################################################

cd $SRC/cheetah

if [ ! -f .extracted ]; then
	rm -rf Cheetah-2.4.4
	tar zxvf Cheetah-2.4.4.tar.gz
	touch .extracted
fi

cd Cheetah-2.4.4

if [ ! -f .built ]; then
	PYTHONPATH=../../python/Python-2.7.3/Lib/:../../setuptools/setuptools-1.3.1 ../../python/Python-2.7.3/hostpython ./setup.py bdist_egg
	touch .built
fi

if [ ! -f .rename ]; then
	mv dist/Cheetah-2.4.4-py2.7-linux-x86_64.egg dist/Cheetah-2.4.4-py2.7.egg
	touch .rename
fi

if [ ! -f .installed ]; then
	cp dist/Cheetah-2.4.4-py2.7.egg $DEST/python_modules
	touch .installed
fi

######## ####################################################################
# YENC # ####################################################################
######## ####################################################################

cd $SRC/yenc

if [ ! -f .extracted ]; then
	rm -rf yenc-0.4.0
	tar zxvf yenc-0.4.0.tar.gz
	touch .extracted
fi

cd yenc-0.4.0

if [ ! -f .patched ]; then
	patch < $PATCHES/yenc.patch
	touch .patched
fi

if [ ! -f .built ]; then
	PYTHONPATH=../../python/Python-2.7.3/Lib/:../../setuptools/setuptools-1.3.1 ../../python/Python-2.7.3/hostpython ./setup.py bdist_egg
	touch .built
fi

if [ ! -f .renamed ]; then
	mv dist/yenc-0.4.0-py2.7-linux-x86_64.egg dist/yenc-0.4.0-py2.7.egg
	touch .renamed
fi

if [ ! -f .installed ]; then
	cp dist/yenc-0.4.0-py2.7.egg $DEST/python_modules
	touch .installed
fi

############# ###############################################################
# pyOpenSSL # ###############################################################
############# ###############################################################

cd $SRC/pyopenssl

if [ ! -f .extracted ]; then
	rm -rf pyOpenSSL-0.13.1
	tar zxvf pyOpenSSL-0.13.1.tar.gz
	touch .extracted
fi

cd pyOpenSSL-0.13.1

if [ ! -f .configured ]; then
	PYTHONPATH=../../python/Python-2.7.3/Lib/ ../../python/Python-2.7.3/hostpython setup.py build_ext -I$DEST/include -L$DEST/lib -R$RPATH
	touch .configured
fi

if [ ! -f .patched ]; then
	sed -i -e "s|from distutils.core import Extension, setup|from setuptools import setup\nfrom distutils.core import Extension|g" setup.py
	touch .patched
fi

if [ ! -f .built ]; then
	PYTHONPATH=../../python/Python-2.7.3/Lib/:../../setuptools/setuptools-1.3.1 ../../python/Python-2.7.3/hostpython setup.py bdist_egg
	touch .built
fi

if [ ! -f .renamed ]; then
	mv dist/pyOpenSSL-0.13.1-py2.7-linux-x86_64.egg dist/pyOpenSSL-0.13.1-py2.7.egg
	touch .renamed
fi

if [ ! -f .installed ]; then
	cp dist/pyOpenSSL-0.13.1-py2.7.egg $DEST/python_modules
	touch .installed
fi

############### #############################################################
# PAR2CMDLINE # #############################################################
############### #############################################################

cd $SRC/par2cmdline

if [ ! -f .extracted ]; then
	rm -rf par2cmdline-0.4
	tar zxvf par2cmdline-0.4.tar.gz
	touch .extracted
fi

cd par2cmdline-0.4

if [ ! -f .patched ]; then
	patch reedsolomon.cpp $PATCHES/reedsolomon.cpp.patch
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
	make clean 
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# UNRAR # ###################################################################
######### ###################################################################

cd $SRC/unrar

if [ ! -f .extracted ]; then
	rm -rf unrar
	tar zxvf unrarsrc-4.2.4.tar.gz
	touch .extracted
fi

cd unrar

if [ ! -f .patched ]; then
	mv makefile.unix Makefile
	patch < $PATCHES/unrar.patch
	touch .patched
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$DEST
	touch .installed
fi

####### #####################################################################
# GIT # #####################################################################
####### #####################################################################

cd $SRC/git

if [ ! -f .extracted ]; then
	rm -rf git-1.8.4.1
	tar zxvf git-1.8.4.1.tar.gz
	touch .extracted
fi

cd git-1.8.4.1

if [ ! -f .built ]; then
	make distclean
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE \
	CC=mipsel-linux-gcc \
	AR=mipsel-linux-ar \
	prefix=$PREFIX \
	FREAD_READS_DIRECTORIES=no \
	SNPRINTF_RETURNS_BOGUS=no \
	NO_TCLTK=yes \
	NO_R_TO_GCC_LINKER=yes \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -pthread -lgettextlib -liconv -lintl"
	touch .built
fi

if [ ! -f .installed ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	make \
	CC=mipsel-linux-gcc \
	AR=mipsel-linux-ar \
	prefix=$PREFIX \
	FREAD_READS_DIRECTORIES=no \
	SNPRINTF_RETURNS_BOGUS=no \
	NO_TCLTK=yes \
	NO_R_TO_GCC_LINKER=yes \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -pthread -lgettextlib -liconv -lintl" \
	install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# STRACE # ##################################################################
########## ##################################################################

cd $SRC/strace

if [ ! -f .extracted ]; then
	rm -rf strace-4.8
	tar xvJf strace-4.8.tar.xz
	touch .extracted
fi

cd strace-4.8

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
# PAM # #####################################################################
####### #####################################################################

cd $SRC/pam

if [ ! -f .extracted ]; then
	rm -rf Linux-PAM-1.1.8
	tar zxvf Linux-PAM-1.1.8.tar.gz
	touch .extracted
fi

cd Linux-PAM-1.1.8

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/pam/pam-no-innetgr.patch
	find libpam -iname \*.h -exec sed -i 's,\/etc\/pam,'"$PREFIX"'\/etc\/pam,g' {} \;
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-read-both-confs \
	--disable-nls
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	sed -i 's,mkdir -p $(namespaceddir),mkdir -p $(DESTDIR)$(namespaceddir),g' \
	modules/pam_namespace/Makefile
	make install DESTDIR=$BASE
	cp -r libpam/include/security/ $DEST/include
	touch .installed
fi

########### #################################################################
# OPENSSH # #################################################################
########### #################################################################

cd $SRC/openssh

if [ ! -f .extracted ]; then
	rm -rf openssh-6.4p1
	tar zxvf openssh-6.4p1.tar.gz
	touch .extracted
fi

cd openssh-6.4p1

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/openssh/openssh-fix-pam-uclibc-pthreads-clash.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-pid-dir=/var/run \
	--with-privsep-path=/var/empty \
	--with-pam
	touch .configured
fi

if [ ! -f .makefile_patch ]; then
	patch < $PATCHES/openssh/remove_check-config.patch
	touch .makefile_patch
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE STRIP_OPT="-s --strip-program=mipsel-linux-strip"
	touch .installed
fi

######## ####################################################################
# HTOP # ####################################################################
######## ####################################################################

cd $SRC/htop

if [ ! -f .extracted ]; then
	rm -rf htop-1.0.2
	tar zxvf htop-1.0.2.tar.gz
	touch .extracted
fi

cd htop-1.0.2

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-unicode
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

########## ##################################################################
# SCREEN # ##################################################################
########## ##################################################################

cd $SRC/screen

if [ ! -f .extracted ]; then
	rm -rf screen-4.0.3
	tar zxvf screen-4.0.3.tar.gz
	touch .extracted
fi

cd screen-4.0.3

if [ ! -f .patched ]; then
	patch < $PATCHES/100-cross_compile_fix.patch
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
# BASH # ####################################################################
######## ####################################################################

cd $SRC/bash

if [ ! -f .extracted ]; then
	rm -rf bash-4.2
	tar zxvf bash-4.2.tar.gz
	touch .extracted
fi

cd bash-4.2

if [ ! -f .patched ]; then
	patch < $PATCHES/bash/001-compile-fix.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-installed-readline
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
# VIM # #####################################################################
####### #####################################################################

cd $SRC/vim

if [ ! -f .extracted ]; then
        rm -rf vim74
        tar xvjf vim-7.4.tar.bz2
        touch .extracted
fi

cd vim74

if [ ! -f .configured ]; then
        LDFLAGS=$LDFLAGS \
        CPPFLAGS=$CPPFLAGS \
        CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
        $CONFIGURE \
	--with-tlib=ncurses \
	--enable-multibyte \
	vim_cv_toupper_broken=no \
	vim_cv_terminfo=yes \
	vim_cv_tty_group=world \
	vim_cv_getcwd_broken=no \
	vim_cv_stat_ignores_slash=no \
	vim_cv_memmove_handles_overlap=yes
        touch .configured
fi

if [ ! -f .built ]; then
        $MAKE
        touch .built
fi

if [ ! -f .installed ]; then
        make install DESTDIR=$BASE STRIP=mipsel-linux-strip
        touch .installed
fi

if [ ! -f .installed_config ]; then
        cp ../.vimrc $DEST
        touch .installed_config
fi

if [ ! -f $DEST/bin/vi ]; then
	ln -s vim $DEST/bin/vi
fi

######## ####################################################################
# TMUX # ####################################################################
######## ####################################################################

cd $SRC/tmux

if [ ! -f .extracted ]; then
        rm -rf tmux-1.8
        tar zxvf tmux-1.8.tar.gz
        touch .extracted
fi

cd tmux-1.8

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

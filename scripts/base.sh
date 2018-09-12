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

######### ###################################################################
# BZIP2 # ###################################################################
######### ###################################################################

BZIP2_VERSION=1.0.6

cd $SRC/bzip2

if [ ! -f .extracted ]; then
	rm -rf bzip2-${BZIP2_VERSION}
	tar zxvf bzip2-${BZIP2_VERSION}.tar.gz
	touch .extracted
fi

cd bzip2-${BZIP2_VERSION}

if [ ! -f .patched ]; then
	patch < $PATCHES/bzip2/bzip2.patch
	patch < $PATCHES/bzip2/bzip2_so.patch
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

ZLIB_VERSION=1.2.11

cd $SRC/zlib

if [ ! -f .extracted ]; then
	rm -rf zlib-${ZLIB_VERSION}
	tar zxvf zlib-${ZLIB_VERSION}.tar.gz
	touch .extracted
fi

cd zlib-${ZLIB_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	CROSS_PREFIX=$DESTARCH-linux- \
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

LZO_VERSION=2.10

cd $SRC/lzo

if [ ! -f .extracted ]; then
	rm -rf lzo-${LZO_VERSION}
	tar zxvf lzo-${LZO_VERSION}.tar.gz
	touch .extracted
fi

cd lzo-${LZO_VERSION}

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

XZ_UTILS_VERSION=5.2.4

cd $SRC/xz

if [ ! -f .extracted ]; then
	rm -rf xz-${XZ_UTILS_VERSION}
	tar zxvf xz-${XZ_UTILS_VERSION}.tar.gz
	touch .extracted
fi

cd xz-${XZ_UTILS_VERSION}

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

OPENSSL_VERSION=1.0.2p

cd $SRC/openssl

if [ ! -f .extracted ]; then
	rm -rf openssl-${OPENSSL_VERSION}
	tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
	touch .extracted
fi

cd openssl-${OPENSSL_VERSION}

if [ "$DESTARCH" == "mipsel" ];then
	os=linux-mips32
fi

if [ "$DESTARCH" == "arm" ];then
	os="linux-armv4 -march=armv7-a -mtune=cortex-a9"
fi

if [ ! -f .configured ]; then
	./Configure $os \
	-Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 \
	-Wl,-rpath,$RPATH -Wl,-rpath-link=$RPATH \
	--prefix=$PREFIX shared zlib \
	--with-zlib-lib=$DEST/lib \
	--with-zlib-include=$DEST/include
	touch .configured
fi

if [ ! -f .built ]; then
	make CC=$DESTARCH-linux-gcc
	touch .built
fi

if [ ! -f .installed ]; then
	make install CC=$DESTARCH-linux-gcc INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl
	touch .installed
fi

############ ################################################################
# LIBICONV # ################################################################
############ ################################################################

LIBICONV_VERSION=1.15

cd $SRC/libiconv

if [ ! -f .extracted ]; then
	rm -rf libiconv-${LIBICONV_VERSION}
	tar zxvf libiconv-${LIBICONV_VERSION}.tar.gz
	touch .extracted
fi

cd libiconv-${LIBICONV_VERSION}

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
# GETTEXT # #################################################################
########### #################################################################

GETTEXT_VERSION=0.19.8.1

cd $SRC/gettext

if [ ! -f .extracted ]; then
	rm -rf gettext-${GETTEXT_VERSION}
	tar zxvf gettext-${GETTEXT_VERSION}.tar.gz
	touch .extracted
fi

cd gettext-${GETTEXT_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/gettext/spawn.patch
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

if [ ! -f .edit_sed ]; then
        sed -i 's,'"$PREFIX"'\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
        $DEST/lib/libintl.la
        touch .edit_sed
fi

######## ####################################################################
# FLEX # ####################################################################
######## ####################################################################

FLEX_VERSION=2.6.0

cd $SRC/flex

if [ ! -f .extracted ]; then
	rm -rf flex-${FLEX_VERSION}
	tar zxvf flex-${FLEX_VERSION}.tar.gz
	touch .extracted
fi

cd flex-${FLEX_VERSION}

if [ ! -f .patched ]; then
	sed -i '/tests/d' Makefile.in
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes
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

CURL_VERSION=7.61.1

cd $SRC/curl

if [ ! -f .extracted ]; then
	rm -rf curl-${CURL_VERSION}
	tar zxvf curl-${CURL_VERSION}.tar.gz
	touch .extracted
fi

cd curl-${CURL_VERSION}

if [ ! -f .configured ]; then
	PKG_CONFIG_PATH="$DEST/lib/pkgconfig" \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-ssl=$DEST \
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
	curl https://curl.haxx.se/ca/cacert.pem | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}'
	c_rehash .
	touch $SRC/curl/curl-${CURL_VERSION}/.certs_installed
fi

######### ###################################################################
# EXPAT # ###################################################################
######### ###################################################################

EXPAT_VERSION=2.2.6

cd $SRC/expat

if [ ! -f .extracted ]; then
	rm -rf cd expat-${EXPAT_VERSION}
	tar xvjf expat-${EXPAT_VERSION}.tar.bz2
	touch .extracted
fi

cd expat-${EXPAT_VERSION}

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

LIBPCAP_VERSION=1.9.0

cd $SRC/libpcap

if [ ! -f .extracted ]; then
	rm -rf libpcap-${LIBPCAP_VERSION}
	tar zxvf libpcap-${LIBPCAP_VERSION}.tar.gz
	touch .extracted
fi

cd libpcap-${LIBPCAP_VERSION}

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

LIBFFI_VERSION=3.2.1

cd $SRC/libffi

if [ ! -f .extracted ]; then
	rm -rf libffi-${LIBFFI_VERSION}
	tar zxvf libffi-${LIBFFI_VERSION}.tar.gz
	touch .extracted
fi

cd libffi-${LIBFFI_VERSION}

if [ ! -f .patched ] && [ "$DESTARCH" == "mipsel" ];then
	patch -p1 < $PATCHES/libffi/mips.softfloat.patch
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
# NCURSES # #################################################################
########### #################################################################

NCURSES_VERSION=6.1

cd $SRC/ncurses

if [ ! -f .extracted ]; then
	rm -rf ncurses-${NCURSES_VERSION}
	tar zxvf ncurses-${NCURSES_VERSION}.tar.gz
	touch .extracted
fi

cd ncurses-${NCURSES_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="-P $CPPFLAGS" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-widec \
	--enable-overwrite \
	--with-normal \
	--with-shared \
	--enable-rpath \
	--with-fallbacks=xterm \
	--disable-stripping
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

if [ ! -f .linked ]; then
	ln -sf libncursesw.a $DEST/lib/libncurses.a
	ln -sf libncursesw.so $DEST/lib/libncurses.so
	ln -sf libncursesw.so.6 $DEST/lib/libncurses.so.6
	ln -sf libncursesw.so.6.0 $DEST/lib/libncurses.so.6.0
	ln -sf libncurses++w.a $DEST/lib/libncurses++.a
	ln -sf libncursesw_g.a $DEST/lib/libncurses_g.a
	ln -sf libncursesw.a $DEST/lib/libcurses.a
	ln -sf libncursesw.so $DEST/lib/libcurses.so
	ln -sf libcurses.so $DEST/lib/libtinfo.so
	touch .linked
fi

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################

LIBREADLINE_VERSION=7.0

cd $SRC/libreadline

if [ ! -f .extracted ]; then
	rm -rf readline-${LIBREADLINE_VERSION}
	tar zxvf readline-${LIBREADLINE_VERSION}.tar.gz
	touch .extracted
fi

cd readline-${LIBREADLINE_VERSION}

if [ ! -f .patched ]; then
	patch < $PATCHES/readline/readline.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	bash_cv_wcwidth_broken=no \
	bash_cv_func_sigsetjmp=yes
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

LIBGDBM_VERSION=1.18

cd $SRC/libgdbm

if [ ! -f .extracted ]; then
	rm -rf gdbm-${LIBGDBM_VERSION}
	tar zxvf gdbm-${LIBGDBM_VERSION}.tar.gz
	touch .extracted
fi

cd gdbm-${LIBGDBM_VERSION}

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

TCL_VERSION=8.6.8

cd $SRC/tcl

if [ ! -f .extracted ]; then
	rm -rf cd tcl${TCL_VERSION}/unix
	tar zxvf tcl${TCL_VERSION}-src.tar.gz
	touch .extracted
fi

cd tcl${TCL_VERSION}/unix

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

BDB_VERSION=4.7.25

cd $SRC/bdb

if [ ! -f .extracted ]; then
	rm -rf db-${BDB_VERSION}
	tar zxvf db-${BDB_VERSION}.tar.gz
	touch .extracted
fi

cd  db-${BDB_VERSION}/build_unix

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	../dist/$CONFIGURE \
	--enable-cxx \
	--enable-tcl \
	--enable-compat185 \
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

SQLITE_VERSION=3240000

cd $SRC/sqlite

if [ ! -f .extracted ]; then
	rm -rf sqlite-autoconf-${SQLITE_VERSION}
	tar zxvf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	touch .extracted
fi

cd sqlite-autoconf-${SQLITE_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
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

########## ##################################################################
# LIBXML # ##################################################################
########## ##################################################################

LIBXML2_VERSION=2.9.8

cd $SRC/libxml2

if [ ! -f .extracted ]; then
	rm -rf libxml2-${LIBXML2_VERSION}
	tar zxvf libxml2-${LIBXML2_VERSION}.tar.gz
	touch .extracted
fi

cd libxml2-${LIBXML2_VERSION}

if [ ! -f .configured ]; then
	Z_CFLAGS=-I$DEST/include \
	Z_LIBS=-L$DEST/lib \
	LDFLAGS="-lz -llzma $LDFLAGS" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-python \
	--with-zlib=$BASE \
	--with-lzma=$BASE
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
	sed -i 's,'"$PREFIX"'\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
	$DEST/lib/libxml2.la
	touch .edit_sed
fi

if [ ! -f .edit_sed2 ]; then
	sed -i 's,'"$PREFIX"'\/lib\/liblzma.la,'"$DEST"'\/lib\/liblzma.la,g' \
	$DEST/lib/libxml2.la
	touch .edit_sed2
fi

########### #################################################################
# LIBXSLT # #################################################################
########### #################################################################

LIBXSLT_VERSION=1.1.32

cd $SRC/libxslt

if [ ! -f .extracted ]; then
	rm -rf libxslt-${LIBXSLT_VERSION}
	tar zxvf libxslt-${LIBXSLT_VERSION}.tar.gz
	touch .extracted
fi

cd libxslt-${LIBXSLT_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-libxml-src=$SRC/libxml2/libxml2-${LIBXML2_VERSION} \
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

LIBSIGCPLUSPLUS_VERSION=2.4.1

cd $SRC/libsigc++

if [ ! -f .extracted ]; then
	rm -rf libsigc++-${LIBSIGCPLUSPLUS_VERSION}
	tar xvJf libsigc++-${LIBSIGCPLUSPLUS_VERSION}.tar.xz
	touch .extracted
fi

cd libsigc++-${LIBSIGCPLUSPLUS_VERSION}

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
# LIBPAR2 # #################################################################
########### #################################################################

LIBPAR2_VERSION=0.4

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/libpar2

if [ ! -f .extracted ]; then
	rm -rf libpar2-${LIBPAR2_VERSION}
	tar zxvf libpar2-${LIBPAR2_VERSION}.tar.gz
	touch .extracted
fi

cd libpar2-${LIBPAR2_VERSION}

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

LIBEVENT_VERSION=2.0.22

cd $SRC/libevent

if [ ! -f .extracted ]; then
	rm -rf libevent-${LIBEVENT_VERSION}-stable
	tar zxvf libevent-${LIBEVENT_VERSION}-stable.tar.gz
	touch .extracted
fi

cd libevent-${LIBEVENT_VERSION}-stable

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

################## ##########################################################
# LIBMYSQLCLIENT # ##########################################################
################## ##########################################################

LIBMYSQLCLIENT_VERSION=6.1.6

cd $SRC/libmysqlclient

if [ ! -f .extracted ]; then
	rm -rf mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src-native
	tar zxvf mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src.tar.gz
	cp -r mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src-native
	touch .extracted
fi

cd mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src-native

if [ ! -f .built_native ]; then
	cmake .
	make
	touch .built_native
fi

cd ../mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/libmysqlclient/libmysqlclient.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DINSTALL_INCLUDEDIR=include/mysql \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DHAVE_GCC_ATOMIC_BUILTINS=1 \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	./
        touch .configured
fi

if [ ! -f .built ]; then
	make || true
	cp ../mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src-native/extra/comp_err ./extra/comp_err
	make
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	cp -r $DEST/include/mysql/mysql/ $DEST/include/
	rm -rf $DEST/include/mysql/mysql
	touch .installed
fi

######## ####################################################################
# PERL # ####################################################################
######## ####################################################################

PERL_VERSION=5.28.0
PERL_CROSS_VERSION=1.2

cd $SRC/perl

if [ ! -f .extracted ]; then
	rm -rf perl-${PERL_VERSION}
	tar zxvf perl-${PERL_VERSION}.tar.gz
	tar zxvf perl-cross-${PERL_CROSS_VERSION}.tar.gz -C perl-${PERL_VERSION} --strip 1
	touch .extracted
fi

cd perl-${PERL_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS="-Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 -Wl,-rpath,$RPATH" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure \
	--prefix=$PREFIX \
	--target=$DESTARCH-linux \
	--use-threads \
	-Duseshrplib
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

PCRE_VERSION=8.42

cd $SRC/pcre

if [ ! -f .extracted ]; then
	rm -rf pcre-${PCRE_VERSION}
	tar zxvf pcre-${PCRE_VERSION}.tar.gz
	touch .extracted
fi

cd pcre-${PCRE_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-pcregrep-libz \
	--enable-pcregrep-libbz2 \
	--enable-pcretest-libreadline \
	--enable-unicode-properties \
	--enable-jit
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

PYTHON_VERSION=2.7.3

cd $SRC/python

if [ ! -f .extracted ]; then
	rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}-native
	tar zxvf Python-${PYTHON_VERSION}.tgz
	cp -r Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}-native
	touch .extracted
fi

cd Python-${PYTHON_VERSION}-native

if [ ! -f .patched_native ]; then
	patch -p1 < $PATCHES/python/python_asdl.patch
	touch .patched_native
fi

if [ ! -f .built_native ]; then
	./configure
	$MAKE
	touch .built_native
fi

cd ../Python-${PYTHON_VERSION}

if [ ! -f .patched ]; then
	patch < $PATCHES/python/python-drobo.patch
	patch -p1 < $PATCHES/python/python_asdl.patch
	patch -p1 < $PATCHES/python/002_readline63.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	AR=$DESTARCH-linux-ar \
	RANLIB=$DESTARCH-linux-ranlib \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="-I$DEST/lib/libffi-3.2.1/include $CPPFLAGS" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--build=`uname -m`-linux-gnu \
	--with-dbmliborder=gdbm:bdb \
	--with-threads \
	--with-system-ffi \
	--enable-shared
	touch .configured
fi

if [ ! -f .copied ]; then
	cp ../Python-${PYTHON_VERSION}-native/python ./hostpython
	cp ../Python-${PYTHON_VERSION}-native/Parser/pgen Parser/hostpgen
	touch .copied
fi

if [ ! -f .built ]; then
	$MAKE \
	HOSTPYTHON=./hostpython \
	HOSTPGEN=./Parser/hostpgen \
	CROSS_COMPILE=$DESTARCH-linux- \
	CROSS_COMPILE_TARGET=yes \
	HOSTDESTARCH=$DESTARCH-linux \
	BUILDDESTARCH=`uname -m`-linux-gnu
	touch .built
fi

if [ ! -f .installed ]; then
	make install \
	DESTDIR=$BASE \
	HOSTPYTHON=../Python-${PYTHON_VERSION}-native/python \
	CROSS_COMPILE=$DESTARCH-linux- \
	CROSS_COMPILE_TARGET=yes
	touch .installed
fi

cd $SRC/python/Python-${PYTHON_VERSION}/build/

if [ ! -f .rename_and_move ]; then
	mv lib.linux-`uname -m`-2.7/ lib.linux-$DESTARCH-2.7/
	cp -R ../../Python-${PYTHON_VERSION}-native/build/lib.linux-`uname -m`-2.7/ .
	touch .rename_and_move
fi

########### #################################################################
# CHEETAH # #################################################################
########### #################################################################

CHEETAH_VERSION=3.1.0

cd $SRC/cheetah

if [ ! -f .extracted ]; then
	rm -rf Cheetah3-${CHEETAH_VERSION}
	tar zxvf Cheetah3-${CHEETAH_VERSION}.tar.gz
	touch .extracted
fi

cd Cheetah3-${CHEETAH_VERSION}

if [ ! -f .built ]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	./setup.py \
	build
	touch .built
fi

if [ ! -f .installed ]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	./setup.py \
	install \
	--prefix=$PREFIX \
	--root=$BASE
	touch .installed
fi

######## ####################################################################
# YENC # ####################################################################
######## ####################################################################

YENC_VERSION=0.4.0

cd $SRC/yenc

if [ ! -f .extracted ]; then
	rm -rf yenc-${YENC_VERSION}
	tar zxvf yenc-${YENC_VERSION}.tar.gz
	touch .extracted
fi

cd yenc-${YENC_VERSION}

if [ ! -f .built ]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	./setup.py \
	build
	touch .built
fi

if [ ! -f .installed ]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	./setup.py \
	install \
	--prefix=$PREFIX \
	--root=$BASE
	touch .installed
fi

############# ###############################################################
# pyOpenSSL # ###############################################################
############# ###############################################################

PYOPENSSL_VERSION=0.13.1

cd $SRC/pyopenssl

if [ ! -f .extracted ]; then
	rm -rf pyOpenSSL-${PYOPENSSL_VERSION}
	tar zxvf pyOpenSSL-${PYOPENSSL_VERSION}.tar.gz
	touch .extracted
fi

cd pyOpenSSL-${PYOPENSSL_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/pyopenssl/010-openssl.patch
        touch .patched
fi

if [ ! -f .built ]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	setup.py \
	build_ext \
	-I$DEST/include \
	-L$DEST/lib \
	-R$RPATH
	touch .built
fi


if [ ! -f .installed ]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	setup.py \
	install \
	--prefix=$PREFIX \
	--root=$BASE
	touch .installed
fi

############### #############################################################
# PAR2CMDLINE # #############################################################
############### #############################################################

PAR2CMDLINE_VERSION=0.8.0

cd $SRC/par2cmdline

if [ ! -f .extracted ]; then
	rm -rf par2cmdline-${PAR2CMDLINE_VERSION}
	tar zxvf par2cmdline-${PAR2CMDLINE_VERSION}.tar.gz
	touch .extracted
fi

cd par2cmdline-${PAR2CMDLINE_VERSION}

if [ ! -f .configured ]; then
	aclocal
	automake --add-missing
	autoconf
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

UNRAR_VERSION=5.6.6

cd $SRC/unrar

if [ ! -f .extracted ]; then
	rm -rf unrar
	tar zxvf unrarsrc-${UNRAR_VERSION}.tar.gz
	touch .extracted
fi

cd unrar

if [ ! -f .patched ]; then
	patch < $PATCHES/unrar/unrar.patch
	touch .patched
fi

if [ ! -f .built ]; then
	make
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$DEST
	touch .installed
fi

####### #####################################################################
# GIT # #####################################################################
####### #####################################################################

GIT_VERSION=2.19.0

cd $SRC/git

if [ ! -f .extracted ]; then
	rm -rf git-${GIT_VERSION}
	tar zxvf git-${GIT_VERSION}.tar.gz
	touch .extracted
fi

cd git-${GIT_VERSION}

if [ ! -f .built ]; then
	make distclean
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE \
	CC=$DESTARCH-linux-gcc \
	AR=$DESTARCH-linux-ar \
	prefix=$PREFIX \
	FREAD_READS_DIRECTORIES=no \
	SNPRINTF_RETURNS_BOGUS=no \
	NO_TCLTK=yes \
	NO_R_TO_GCC_LINKER=yes \
	USE_LIBPCRE1=yes \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -lgettextlib -liconv -lintl -lpcre"
	touch .built
fi

if [ ! -f .installed ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	make \
	CC=$DESTARCH-linux-gcc \
	AR=$DESTARCH-linux-ar \
	prefix=$PREFIX \
	FREAD_READS_DIRECTORIES=no \
	SNPRINTF_RETURNS_BOGUS=no \
	NO_TCLTK=yes \
	NO_R_TO_GCC_LINKER=yes \
	USE_LIBPCRE1=yes \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -lgettextlib -liconv -lintl -lpcre" \
	install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# STRACE # ##################################################################
########## ##################################################################

STRACE_VERSION=4.21

cd $SRC/strace

if [ ! -f .extracted ]; then
	rm -rf strace-${STRACE_VERSION}
	tar xvJf strace-${STRACE_VERSION}.tar.xz
	touch .extracted
fi

cd strace-${STRACE_VERSION}

if [ "$DESTARCH" == "mipsel" ];then
	straceconfig=ac_cv_header_linux_dm_ioctl_h=no
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	$straceconfig
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

LINUX_PAM_VERSION=1.3.0

cd $SRC/pam

if [ ! -f .extracted ]; then
	rm -rf Linux-PAM-${LINUX_PAM_VERSION}
	tar zxvf Linux-PAM-${LINUX_PAM_VERSION}.tar.gz
	touch .extracted
fi

cd Linux-PAM-${LINUX_PAM_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/pam/0002-Conditionally-compile-per-ruserok-availability.patch
	find libpam -iname \*.h -exec sed -i 's,\/etc\/pam,'"$PREFIX"'\/etc\/pam,g' {} \;
	aclocal
	automake --add-missing
	autoconf

	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-read-both-confs \
	--disable-nls \
	ac_cv_search_crypt=no
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

OPENSSH_VERSION=7.8p1

cd $SRC/openssh

if [ ! -f .extracted ]; then
	rm -rf openssh-${OPENSSH_VERSION}
	tar zxvf openssh-${OPENSSH_VERSION}.tar.gz
	touch .extracted
fi

cd openssh-${OPENSSH_VERSION}

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
	--sysconfdir=$PREFIX/etc/ssh \
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
	make install DESTDIR=$BASE STRIP_OPT="-s --strip-program=$DESTARCH-linux-strip"
	touch .installed
fi

######## ####################################################################
# HTOP # ####################################################################
######## ####################################################################

HTOP_VERSION=2.2.0

cd $SRC/htop

if [ ! -f .extracted ]; then
	rm -rf htop-${HTOP_VERSION}
	tar zxvf htop-${HTOP_VERSION}.tar.gz
	touch .extracted
fi

cd htop-${HTOP_VERSION}

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
# SCREEN # ##################################################################
########## ##################################################################

SCREEN_VERSION=4.6.2

cd $SRC/screen

if [ ! -f .extracted ]; then
	rm -rf screen-${SCREEN_VERSION}
	tar zxvf screen-${SCREEN_VERSION}.tar.gz
	touch .extracted
fi

cd screen-${SCREEN_VERSION}

if [ ! -f .patched ]; then
	patch < $PATCHES/screen/screen.patch
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

BASH_VERSION=4.4.18

cd $SRC/bash

if [ ! -f .extracted ]; then
	rm -rf bash-${BASH_VERSION}
	tar zxvf bash-${BASH_VERSION}.tar.gz
	touch .extracted
fi

cd bash-${BASH_VERSION}

if [ ! -f .patched ]; then
	patch < $PATCHES/bash/001-compile-fix.patch
	patch < $PATCHES/bash/002-force-internal-readline.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-bash-malloc \
	bash_cv_wexitstatus_offset=8 \
	bash_cv_getcwd_malloc=yes \
	bash_cv_func_sigsetjmp=present \
	bash_cv_func_snprintf=yes \
	bash_cv_func_vsnprintf=yes \
	bash_cv_printf_a_format=yes \
	bash_cv_job_control_missing=present \
	bash_cv_unusable_rtsigs=no \
	bash_cv_sys_named_pipes=present \
	bash_cv_func_ctype_nonascii=no \
	bash_cv_dup2_broken=no \
	bash_cv_pgrp_pipe=no \
	bash_cv_sys_siglist=no \
	bash_cv_under_sys_siglist=no \
	bash_cv_opendir_not_robust=no \
	bash_cv_ulimit_maxfds=no \
	bash_cv_getenv_redef=yes \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_wcontinued_broken=no \
	bash_cv_func_strcoll_broken=no

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
# ZSH # #####################################################################
####### #####################################################################

ZSH_VERSION=5.6.1

cd $SRC/zsh

if [ ! -f .extracted ]; then
	rm -rf zsh-${ZSH_VERSION}
	tar xvJf zsh-${ZSH_VERSION}.tar.xz
	touch .extracted
fi

cd zsh-${ZSH_VERSION}

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
# VIM # #####################################################################
####### #####################################################################

VIM_VERSION=8.1

cd $SRC/vim

if [ ! -f .extracted ]; then
	rm -rf vim81
	tar xvjf vim-${VIM_VERSION}.tar.bz2
	touch .extracted
fi

cd vim81

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-tlib=ncurses \
	--enable-multibyte \
	vim_cv_tgetent=zero \
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
	make install DESTDIR=$BASE STRIP=$DESTARCH-linux-strip
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

TMUX_VERSION=2.7

cd $SRC/tmux

if [ ! -f .extracted ]; then
	rm -rf tmux-${TMUX_VERSION}
	tar zxvf tmux-${TMUX_VERSION}.tar.gz
	touch .extracted
fi

cd tmux-${TMUX_VERSION}

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
# UNZIP # ###################################################################
######### ###################################################################

UNZIP_VERSION=60

cd $SRC/unzip

if [ ! -f .extracted ]; then
	rm -rf unzip${UNZIP_VERSION}
	tar zxvf unzip${UNZIP_VERSION}.tar.gz
	touch .extracted
fi

cd unzip${UNZIP_VERSION}

if [ ! -f .patched ]; then
	patch unix/Makefile < $PATCHES/unzip/unzip.patch
	touch .patched
fi

if [ ! -f .built ]; then
	PREFIX=$PREFIX \
	RPATH=$RPATH \
	make -f unix/Makefile  linux_noasm
	touch .built
fi

if [ ! -f .installed ]; then
	make prefix=$DEST install
	touch .installed
fi

######## ####################################################################
# GZIP # ####################################################################
######## ####################################################################

GZIP_VERSION=1.9

cd $SRC/gzip

if [ ! -f .extracted ]; then
	rm -rf gzip-${GZIP_VERSION}
	tar xvJf gzip-${GZIP_VERSION}.tar.xz
	touch .extracted
fi

cd gzip-${GZIP_VERSION}

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
# BOOST  # ##################################################################
########## ##################################################################

BOOST_VERSION=1_67_0

cd $SRC/boost

if [ ! -f .extracted ]; then
	rm -rf boost_${BOOST_VERSION} build
	tar xvjf boost_${BOOST_VERSION}.tar.bz2
	mkdir -p $SRC/boost/build
	touch .extracted
fi

cd boost_${BOOST_VERSION}

if ! [[ -f .configured ]]; then
	echo  "using gcc : $DESTARCH : $DESTARCH-linux-g++ ;" > $SRC/boost/user-config.jam
	./bootstrap.sh
	touch .configured
fi

if ! [[ -f .built ]]; then
	HOME=$SRC/boost \
	./b2 \
	--prefix=$DEST \
	--build-dir=$SRC/boost/build \
	--without-python \
	toolset=gcc-$DESTARCH \
	threading=multi \
	variant=release \
	cxxflags=$CXXFLAGS \
	-j`nproc` \
	-sBZIP2_INCLUDE=$DEST/include \
	-sBZIP2_LIBPATH=$DEST/lib \
	-sZLIB_INCLUDE=$DEST/include \
	-sZLIB_LIBPATH=$DEST/lib \
	-sLZMA_INCLUDE=$DEST/include \
	-sLZMA_LIBPATH=$DEST/lib \
	install \
	|| true
	touch .built
fi

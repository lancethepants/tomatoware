#!/bin/bash

source ./scripts/environment.sh

if [[ "$DESTARCH" == "aarch64" || "$DESTARCH" == "x86_64" ]]; then
	mkdir -p $DEST/lib
	ln -sf lib $DEST/lib64
fi

######### ###################################################################
# BZIP2 # ###################################################################
######### ###################################################################
Status "compiling bzip2"

BZIP2_VERSION=1.0.8

cd $SRC/bzip2

if [ ! -f .extracted ]; then
	rm -rf bzip2 bzip2-${BZIP2_VERSION}
	tar zxvf bzip2-${BZIP2_VERSION}.tar.gz
	mv bzip2-${BZIP2_VERSION} bzip2
	touch .extracted
fi

cd bzip2

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/bzip2/bzip2.patch
	patch -p1 < $PATCHES/bzip2/bzip2_so.patch
	touch .patched
fi

if [ ! -f .built ]; then
	EABI=$EABI \
	_LDFLAGS=$LDFLAGS \
	$MAKE
	EABI=$EABI \
	_LDFLAGS=$LDFLAGS \
	$MAKE -f Makefile-libbz2_so
	touch .built
fi

if [ ! -f .installed ]; then
	EABI=$EABI \
	_LDFLAGS=$LDFLAGS \
	$MAKE1 install PREFIX=$DEST
	touch .installed
fi

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################
Status "compiling zlib"

ZLIB_VERSION=1.3.1

cd $SRC/zlib

if [ ! -f .extracted ]; then
	rm -rf zlib zlib-${ZLIB_VERSION}
	tar xvJf zlib-${ZLIB_VERSION}.tar.xz
	mv zlib-${ZLIB_VERSION} zlib
	touch .extracted
fi

cd zlib

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	CROSS_PREFIX=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI- \
	./configure \
	--prefix=$PREFIX
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# LZO # #####################################################################
####### #####################################################################
Status "compiling lzo"

LZO_VERSION=2.10

cd $SRC/lzo

if [ ! -f .extracted ]; then
	rm -rf lzo lzo-${LZO_VERSION}
	tar zxvf lzo-${LZO_VERSION}.tar.gz
	mv lzo-${LZO_VERSION} lzo
	touch .extracted
fi

cd lzo

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# LZ4 # #####################################################################
####### #####################################################################
Status "compiling lz4"

LZ4_VERSION=1.9.4

cd $SRC/lz4

if [ ! -f .extracted ]; then
	rm -rf lz4 lz4-${LZ4_VERSION}
	tar zxvf lz4-${LZ4_VERSION}.tar.gz
	mv lz4-${LZ4_VERSION} lz4
	touch .extracted
fi

cd lz4

if [ ! -f .built ]; then
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	CXX=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++ \
	PREFIX=$PREFIX \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	CXX=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++ \
	PREFIX=$PREFIX \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

############ ################################################################
# XZ UTILS # ################################################################
############ ################################################################
Status "compiling xz utils"

XZ_UTILS_VERSION=5.6.2

cd $SRC/xz

if [ ! -f .extracted ]; then
	rm -rf xz xz-${XZ_UTILS_VERSION}
	tar xvJf xz-${XZ_UTILS_VERSION}.tar.xz
	mv xz-${XZ_UTILS_VERSION} xz
	touch .extracted
fi

cd xz

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-rpath
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# ZSTD # ####################################################################
######## ####################################################################
Status "compiling zstd"

ZSTD_VERSION=1.5.6

cd $SRC/zstd

if [ ! -f .extracted ]; then
	rm -rf zstd zstd-${ZSTD_VERSION}
	tar zxvf zstd-${ZSTD_VERSION}.tar.gz
	mv zstd-${ZSTD_VERSION} zstd
	touch .extracted
fi

cd zstd

if [ ! -f .built ]; then
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	CXX=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++ \
	PREFIX=$PREFIX \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	CXX=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++ \
	PREFIX=$PREFIX \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# P7ZIP # ###################################################################
######### ###################################################################
Status "compiling p7zip"

P7ZIP_VERSION=17.04

cd $SRC/p7zip

if [ ! -f .extracted ]; then
	rm -rf p7zip p7zip-${P7ZIP_VERSION}
	tar zxvf p7zip-${P7ZIP_VERSION}.tar.gz
	mv p7zip-${P7ZIP_VERSION} p7zip
	touch .extracted
fi

cd p7zip

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/p7zip/p7zip.patch
	touch .patched
fi


if [ ! -f .built ]; then
	$MAKE \
	LDFLAGS="$LDFLAGS" \
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	CXX=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++ \
	OPTFLAGS="$CFLAGS" \
	-j`nproc`
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 \
	install \
	DEST_DIR=$BASE \
	DEST_HOME=$PREFIX
	touch .installed
fi

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################
Status "compiling openssl"

OPENSSL_VERSION=3.3.1

cd $SRC/openssl

if [ ! -f .extracted ]; then
	rm -rf openssl openssl-${OPENSSL_VERSION}
	tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
	mv openssl-${OPENSSL_VERSION} openssl
	touch .extracted
fi

cd openssl

if [ ! -f .patched ] && [[ "$DESTARCH" == "arm" || "$DESTARCH" == "mipsel" ]]; then
	patch -p1 < $PATCHES/openssl/140-allow-prefer-chacha20.patch
	touch .patched
fi

if [ "$DESTARCH" == "mipsel" ];then
	os="linux-mips32 -mips32 -mtune=mips32"
fi

if [ "$DESTARCH" == "arm" ];then
	os="linux-armv4 -march=armv7-a -mtune=cortex-a9"
fi

if [ "$DESTARCH" == "aarch64" ];then
	os="linux-aarch64 -mcpu=cortex-a53"
fi

if [ "$DESTARCH" == "x86_64" ];then
	os="linux-x86_64 -march=x86-64-v2"
fi

if [ ! -f .configured ]; then
	./Configure $os \
	$LDFLAGS \
	--prefix=$PREFIX \
	shared no-zlib \
	-DOPENSSL_PREFER_CHACHA_OVER_GCM
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE1 \
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	AR=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-ar \
	RANLIB=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-ranlib
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 \
	install \
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	AR=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-ar \
	RANLIB=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-ranlib \
	INSTALLTOP=$DEST \
	OPENSSLDIR=$DEST/ssl
	touch .installed
fi

######## ####################################################################
# FLEX # ####################################################################
######## ####################################################################
Status "compiling flex"

FLEX_VERSION=2.6.0

cd $SRC/flex

if [ ! -f .extracted ]; then
	rm -rf flex flex-${FLEX_VERSION}
	tar xvJf flex-${FLEX_VERSION}.tar.xz
	mv flex-${FLEX_VERSION} flex
	touch .extracted
fi

cd flex

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
	--disable-rpath \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# CURL # ####################################################################
######## ####################################################################
Status "compiling curl"

CURL_VERSION=8.8.0

cd $SRC/curl

if [ ! -f .extracted ]; then
	rm -rf curl curl-${CURL_VERSION}
	tar xvJf curl-${CURL_VERSION}.tar.xz
	mv curl-${CURL_VERSION} curl
	touch .extracted
fi

cd curl

if [ ! -f .configured ]; then
	PKG_CONFIG_PATH="$DEST/lib/pkgconfig" \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-openssl=$DEST \
	--with-zstd=$DEST \
	--with-ca-path=$PREFIX/ssl/certs
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# CERTS # ###################################################################
######### ###################################################################
Status "compiling certs"

if [ ! -f $SRC/certs/.installed ]; then
	rm -rf $DEST/ssl/certs
	mkdir -p $DEST/ssl/certs
	cd $DEST/ssl/certs
	curl -o $SRC/certs/cacert.pem --remote-name --time-cond $SRC/certs/cacert.pem https://curl.se/ca/cacert.pem
	cp $SRC/certs/cacert.pem .
	cat cacert.pem | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}'
	rm cacert.pem
	c_rehash .
	cp $SRC/certs/cacert.pem ./ca-certificates.crt
	touch $SRC/certs/.installed
fi

######### ###################################################################
# EXPAT # ###################################################################
######### ###################################################################
Status "compiling expat"

EXPAT_VERSION=2.6.2

cd $SRC/expat

if [ ! -f .extracted ]; then
	rm -rf expat expat-${EXPAT_VERSION}
	tar xvJf expat-${EXPAT_VERSION}.tar.xz
	mv expat-${EXPAT_VERSION} expat
	touch .extracted
fi

cd expat

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# LIBPCAP # #################################################################
########### #################################################################
Status "compiling libpcap"

LIBPCAP_VERSION=1.10.4

cd $SRC/libpcap

if [ ! -f .extracted ]; then
	rm -rf libpcap libpcap-${LIBPCAP_VERSION}
	tar xvJf libpcap-${LIBPCAP_VERSION}.tar.xz
	mv libpcap-${LIBPCAP_VERSION} libpcap
	touch .extracted
fi

cd libpcap

if [ ! -f .patched ] && [ "$DESTARCHLIBC" == "uclibc" ]; then
	patch -p1 < $PATCHES/libpcap/libpcap-no-mod-and-xor.patch
	if [ "$DESTARCH" == "mipsel" ]; then
		patch -p1 < $PATCHES/libpcap/libpcap-no-NETLINK_GENERIC.patch
	fi
	touch .patched
fi

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# LIBFFI # ##################################################################
########## ##################################################################
Status "compiling libffi"

LIBFFI_VERSION=3.4.5

cd $SRC/libffi

if [ ! -f .extracted ]; then
	rm -rf libffi libffi-${LIBFFI_VERSION}
	tar zxvf libffi-${LIBFFI_VERSION}.tar.gz
	mv libffi-${LIBFFI_VERSION} libffi
	touch .extracted
fi

cd libffi

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/libffi/0001-Fix-installation-location-of-libffi.patch
	patch -p1 < $PATCHES/libffi/0002-Fix-use-of-compact-eh-frames-on-MIPS.patch
	patch -p1 < $PATCHES/libffi/0003-libffi-enable-hardfloat-in-the-MIPS-assembly-code.patch
	autoreconf -fsi
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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# NCURSES # #################################################################
########### #################################################################
Status "compiling ncurses"

NCURSES_VERSION=6.5
M=${NCURSES_VERSION%.*}
m=${NCURSES_VERSION#*.}

cd $SRC/ncurses

if [ ! -f .extracted ]; then
	rm -rf ncurses ncurses-native ncurses-${NCURSES_VERSION}
	tar zxvf ncurses-${NCURSES_VERSION}.tar.gz
	mv ncurses-${NCURSES_VERSION} ncurses
	cp -r ncurses ncurses-native
	touch .extracted
fi

cd ncurses-native

if [ ! -f .built-native ]; then
	./configure \
	--prefix=$SRC/ncurses/ncurses-native/install \
	--without-cxx \
	--without-cxx-binding \
	--without-ada \
	--without-debug \
	--without-manpages \
	--without-profile \
	--without-tests \
	--without-curses-h
	$MAKE
	$MAKE1 install
	touch .built-native
fi

cd ../ncurses

if [ ! -f .configured ]; then
	PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig \
	PATH=$SRC/ncurses/ncurses-native/install/bin:$PATH \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-rpath \
	--disable-rpath-hack \
	--enable-widec \
	--enable-overwrite \
	--with-normal \
	--with-shared \
	--with-fallbacks=xterm,xterm-256color \
	--disable-stripping \
	--enable-pc-files \
	--with-pkg-config-libdir=$PREFIX/lib/pkgconfig
	touch .configured
fi

if [ ! -f .built ]; then
	PATH=$SRC/ncurses/ncurses-native/install/bin:$PATH \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	PATH=$SRC/ncurses/ncurses-native/install/bin:$PATH \
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .linked ]; then

	for link in ncurses panel menu form
	do
		ln -sf lib${link}w.a $DEST/lib/lib${link}.a
		ln -sf lib${link}w.so $DEST/lib/lib${link}.so
		ln -sf lib${link}w.so.$M $DEST/lib/lib${link}.so.$M
		ln -sf lib${link}w.so.$M.$m $DEST/lib/lib${link}.so.$M.$m
		ln -sf lib${link}w_g.a $DEST/lib/lib${link}_g.a
		ln -sf ${link}w.pc $DEST/lib/pkgconfig/${link}.pc
	done

	ln -sf libncurses++w.a $DEST/lib/libncurses++.a
	ln -sf libncurses++w_g.a $DEST/lib/libncurses++_g.a
	ln -sf libncursesw.a $DEST/lib/libcurses.a
	ln -sf libncursesw.so $DEST/lib/libcurses.so
	ln -sf libcurses.so $DEST/lib/libtinfo.so
	ln -sf libcurses.a $DEST/lib/libtinfo.a
	ln -sf ncurses++w.pc $DEST/lib/pkgconfig/ncurses++.pc

	touch .linked
fi

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################
Status "compiling libreadline"

LIBREADLINE_VERSION=8.2

cd $SRC/libreadline

if [ ! -f .extracted ]; then
	rm -rf readline readline-${LIBREADLINE_VERSION}
	tar zxvf readline-${LIBREADLINE_VERSION}.tar.gz
	mv readline-${LIBREADLINE_VERSION} readline
	touch .extracted
fi

cd readline

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/readline/0001-curses-link.patch
	patch -p1 < $PATCHES/readline/002-no-rpath.patch
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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# LUA # #####################################################################
####### #####################################################################
Status "compiling lua"

LUA_VERSION=5.4.7

cd $SRC/lua

if [ ! -f .extracted ]; then
	rm -rf lua lua-${LUA_VERSION}
	tar zxvf lua-${LUA_VERSION}.tar.gz
	mv lua-${LUA_VERSION} lua
	touch .extracted
fi

cd lua

if [ ! -f .built ]; then
	$MAKE1 \
	linux \
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	INSTALL_TOP=$BASE$PREFIX \
	MYCFLAGS="$CFLAGS $CPPFLAGS" \
	MYLDFLAGS="$LDFLAGS"
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 \
	linux \
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	INSTALL_TOP=$BASE$PREFIX \
	MYCFLAGS="$CFLAGS $CPPFLAGS" \
	MYLDFLAGS="$LDFLAGS" \
	install \
	DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# LIBGDBM # #################################################################
########### #################################################################
Status "compiling libgdbm"

LIBGDBM_VERSION=1.24

cd $SRC/libgdbm

if [ ! -f .extracted ]; then
	rm -rf gdbm gdbm-${LIBGDBM_VERSION}
	tar zxvf gdbm-${LIBGDBM_VERSION}.tar.gz
	mv gdbm-${LIBGDBM_VERSION} gdbm
	touch .extracted
fi

cd gdbm

if [ ! -f .patched ] && [ "$DESTARCHLIBC" == "uclibc" ]; then
	patch -p1 < $PATCHES/libgdbm/libgdbm.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS -fcommon" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-rpath
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# tcl # #####################################################################
####### #####################################################################
Status "compiling tcl"

TCL_VERSION=8.6.14

cd $SRC/tcl

if [ ! -f .extracted ]; then
	rm -rf tcl tcl${TCL_VERSION}
	tar zxvf tcl${TCL_VERSION}-src.tar.gz
	mv tcl${TCL_VERSION} tcl
	touch .extracted
fi

cd tcl/unix

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-rpath \
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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

############### #############################################################
# BERKELEY DB # #############################################################
############### #############################################################
Status "compiling bdb"

BDB_VERSION=5.3.28

cd $SRC/bdb

if [ ! -f .extracted ]; then
	rm -rf db db-${BDB_VERSION}
	tar zxvf db-${BDB_VERSION}.tar.gz
	mv db-${BDB_VERSION} db
	touch .extracted
fi

cd  db/build_unix

if [ ! -f .patched ]; then

	cp $PATCHES/gnuconfig/config.guess \
	   $PATCHES/gnuconfig/config.sub \
	   $SRC/bdb/db/dist

	if [ "$DESTARCH" == "x86_64" ]; then
		patch -d $SRC/bdb/db -p1 < $PATCHES/bdb/0002-atomic_compare_exchange.patch
	fi
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	../dist/$CONFIGURE \
	--enable-cxx \
	--enable-tcl \
	--enable-compat185 \
	--with-tcl=$DEST/lib \
	--enable-dbm \
	lt_cv_sys_lib_dlsearch_path_spec="$LT_SYS_LIBRARY_PATH"
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# SQLITE # ##################################################################
########## ##################################################################
Status "compiling sqlite"

SQLITE_VERSION=3460000

cd $SRC/sqlite

if [ ! -f .extracted ]; then
	rm -rf sqlite sqlite-autoconf-${SQLITE_VERSION}
	tar zxvf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	mv sqlite-autoconf-${SQLITE_VERSION} sqlite
	touch .extracted
fi

cd sqlite

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE1
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# LIBXML2 # #################################################################
########### #################################################################
Status "compiling libxml2"

LIBXML2_VERSION=2.9.12

cd $SRC/libxml2

if [ ! -f .extracted ]; then
	rm -rf libxml2 libxml2-${LIBXML2_VERSION}
	tar zxvf libxml2-${LIBXML2_VERSION}.tar.gz
	mv libxml2-${LIBXML2_VERSION} libxml2
	touch .extracted
fi

cd libxml2

if [ ! -f .configured ]; then
	Z_CFLAGS=-I$DEST/include \
	Z_LIBS=-L$DEST/lib \
	LDFLAGS=$LDFLAGS \
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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .linked ]; then
	ln -sf libxml2/libxml $DEST/include/libxml
	touch .linked
fi

if [ ! -f .edit_sed ]; then
	sed -i 's,'"$PREFIX"'\/lib\/liblzma.la,'"$DEST"'\/lib\/liblzma.la,g' \
	$DEST/lib/libxml2.la
	touch .edit_sed
fi

########### #################################################################
# LIBXSLT # #################################################################
########### #################################################################
Status "compiling libxslt"

LIBXSLT_VERSION=1.1.34

cd $SRC/libxslt

if [ ! -f .extracted ]; then
	rm -rf libxslt libxslt-${LIBXSLT_VERSION}
	tar zxvf libxslt-${LIBXSLT_VERSION}.tar.gz
	mv libxslt-${LIBXSLT_VERSION} libxslt
	touch .extracted
fi

cd libxslt

if [ ! -f .configured ]; then
	LDFLAGS="$LDFLAGS -lxml2" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-libxml-prefix=$DEST \
	--with-libxml-include-prefix=$DEST \
	--with-libxml-libs-prefix=$DEST \
	--without-python \
	--without-crypto
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

############ ################################################################
# LIBEVENT # ################################################################
############ ################################################################
Status "compiling libevent"

LIBEVENT_VERSION=2.1.12

cd $SRC/libevent

if [ ! -f .extracted ]; then
	rm -rf libevent libevent-${LIBEVENT_VERSION}-stable
	tar zxvf libevent-${LIBEVENT_VERSION}-stable.tar.gz
	mv libevent-${LIBEVENT_VERSION}-stable libevent
	touch .extracted
fi

cd libevent

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

################## ##########################################################
# LIBMYSQLCLIENT # ##########################################################
################## ##########################################################
Status "compiling libmysqlclient"

LIBMYSQLCLIENT_VERSION=6.1.6

cd $SRC/libmysqlclient

if [ ! -f .extracted ]; then
	rm -rf mysql-connector-c mysql-connector-c-native mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src
	tar zxvf mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src.tar.gz
	mv mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src mysql-connector-c
	cp -r mysql-connector-c mysql-connector-c-native
	touch .extracted
fi

cd mysql-connector-c-native

if [ ! -f .built_native ]; then
	cmake .
	$MAKE1
	touch .built_native
fi

cd ../mysql-connector-c

if [ ! -f .patched ] && [ "$DESTARCHLIBC" == "uclibc" ]; then
	patch -p1 < $PATCHES/libmysqlclient/libmysqlclient.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DINSTALL_INCLUDEDIR=include/mysql \
	-DCMAKE_C_COMPILER=`which $DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++` \
	-DHAVE_GCC_ATOMIC_BUILTINS=1 \
	-DCMAKE_C_FLAGS="$CFLAGS -Wno-int-conversion" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	./
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE1 || true
	cp ../mysql-connector-c-native/extra/comp_err ./extra/comp_err
	$MAKE1
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	cp -r $DEST/include/mysql/mysql/ $DEST/include/
	rm -rf $DEST/include/mysql/mysql
	touch .installed
fi

######## ####################################################################
# PERL # ####################################################################
######## ####################################################################
Status "compiling perl"

if [ "$DESTARCH" == "aarch64" ]; then
	PERL_CROSS_VERSION=1.3.5
else
	PERL_CROSS_VERSION=1.5.3
fi


cd $SRC/perl

if [ ! -f .extracted ]; then
	rm -rf perl perl-host perl-${PERL_VERSION} native
	tar zxvf perl-${PERL_VERSION}.tar.gz
	tar zxvf perl-cross-${PERL_CROSS_VERSION}.tar.gz -C perl-${PERL_VERSION} --strip 1
	mv perl-${PERL_VERSION} perl
	cp -r perl perl-host
	touch .extracted
fi

cd perl-host

if [ ! -f .configured ]; then
	./configure \
	--prefix=$SRC/perl/native
	$MAKE
	$MAKE1 install
	touch .configured
fi

cd ../perl

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS -Wno-implicit-function-declaration" \
	CFLAGS="$CFLAGS -Wno-implicit-function-declaration" \
	CXXFLAGS=$CXXFLAGS \
	./configure \
	--prefix=$PREFIX \
	--target=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI \
	--use-threads \
	-Duseshrplib
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE1
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# PCRE # ####################################################################
######## ####################################################################
Status "compiling pcre"

PCRE_VERSION=8.45

cd $SRC/pcre

if [ ! -f .extracted ]; then
	rm -rf pcre pcre-${PCRE_VERSION}
	tar xvjf pcre-${PCRE_VERSION}.tar.bz2
	mv pcre-${PCRE_VERSION} pcre
	touch .extracted
fi

cd pcre

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# PCRE2 # ###################################################################
######### ###################################################################
Status "compiling pcre2"

PCRE2_VERSION=10.39

cd $SRC/pcre2

if [ ! -f .extracted ]; then
	rm -rf pcre2 pcre2-${PCRE2_VERSION}
	tar xvjf pcre2-${PCRE2_VERSION}.tar.bz2
	mv pcre2-${PCRE2_VERSION} pcre2
	touch .extracted
fi

cd pcre2

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-pcre2grep-libz \
	--enable-pcre2grep-libbz2 \
	--enable-pcre2test-libreadline \
	--enable-jit \
	--enable-pcre2-8 \
	--enable-pcre2-16 \
	--enable-pcre2-32
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

############### #############################################################
# PAR2CMDLINE # #############################################################
############### #############################################################
Status "compiling par2cmdline"

PAR2CMDLINE_VERSION=0.8.1

cd $SRC/par2cmdline

if [ ! -f .extracted ]; then
	rm -rf par2cmdline par2cmdline-${PAR2CMDLINE_VERSION}
	tar xvjf par2cmdline-${PAR2CMDLINE_VERSION}.tar.bz2
	mv par2cmdline-${PAR2CMDLINE_VERSION} par2cmdline
	touch .extracted
fi

cd par2cmdline

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
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

############## ##############################################################
# UTIL-LINUX # ##############################################################
############## ##############################################################
Status "compiling util-linux"

if [ "$DESTARCH" == "mipsel" ];then
	UTIL_LINUX_VERSION=2.34
else
	UTIL_LINUX_VERSION=2.38.1
fi

cd $SRC/util-linux

if [ ! -f .extracted ]; then
	rm -rf util-linux util-linux-${UTIL_LINUX_VERSION}
	tar xvJf util-linux-${UTIL_LINUX_VERSION}.tar.xz
	mv util-linux-${UTIL_LINUX_VERSION} util-linux
	touch .extracted
fi

cd util-linux

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
	--disable-rpath \
	--disable-mount \
	--disable-chfn-chsh-password \
	--without-python \
	--disable-nls \
	--disable-wall \
	--disable-su \
	--disable-rfkill \
	--disable-raw
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# PYTHON # ##################################################################
########## ##################################################################
Status "compiling python"

PYTHON_VERSION=2.7.18

cd $SRC/python

if [ ! -f .extracted ]; then
	rm -rf Python Python-native Python-${PYTHON_VERSION} native
	tar xvJf Python-${PYTHON_VERSION}.tar.xz
	mv Python-${PYTHON_VERSION} Python
	touch .extracted
fi

cd Python

if [ ! -f .patched ]; then
	for file in $PATCHES/python/*.patch
	do
		patch -p1 < "$file"
	done
	autoreconf -fsi
	cp -r ../Python ../Python-native
	touch .patched
fi

cd ../Python-native

if [ ! -f .built_native ]; then
	LDFLAGS=" -Wl,--enable-new-dtags" \
	./configure \
	--prefix=$SRC/python/native \
	--without-ensurepip \
	--enable-static \
	--without-cxx-main \
	--disable-sqlite3 \
	--disable-tk \
	--with-expat=system \
	--disable-curses \
	--disable-codecs-cjk \
	--disable-nis \
	--enable-unicodedata \
	--disable-dbm \
	--disable-gdbm \
	--disable-bsddb \
	--disable-test-modules \
	--disable-bz2 \
	--disable-ssl \
	--disable-ossaudiodev \
	--disable-pyo-build \
	ac_cv_prog_HAS_HG=/bin/false \
	ac_cv_prog_SVNVERSION=/bin/false
	$MAKE
	$MAKE1 install
	touch .built_native
fi

cd ../Python

if [ ! -f .configured ]; then
	PATH=$SRC/python/native/bin:$PATH \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--build=x86_64-linux-gnu \
	--without-ensurepip \
	--with-system-ffi \
	--enable-shared \
	--disable-pydoc \
	--disable-test-modules \
	--disable-nis \
	--enable-optimizations \
	ac_cv_have_long_long_format=yes \
	ac_cv_file__dev_ptmx=yes \
	ac_cv_file__dev_ptc=yes \
	ac_cv_working_tzset=yes \
	ac_cv_prog_HAS_HG=/bin/false \
	ac_cv_prog_SVNVERSION=/bin/false
	touch .configured
fi

if [ ! -f .built ]; then
	PATH=$SRC/python/native/bin:$PATH \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	PATH=$SRC/python/native/bin:$PATH \
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f $DEST/bin/python ]; then
	ln -s python2 $DEST/bin/python
fi

########### #################################################################
# PYTHON3 # #################################################################
########### #################################################################
Status "compiling python3"

PYTHON3_VERSION=3.11.0

cd $SRC/python3

if [ ! -f .extracted ]; then
	rm -rf Python Python-native Python-${PYTHON3_VERSION} native3
	tar xvJf Python-${PYTHON3_VERSION}.tar.xz
	mv Python-${PYTHON3_VERSION} Python
	touch .extracted
fi

cd Python

if [ ! -f .patched ]; then
	for file in $PATCHES/python3/*.patch
	do
		patch -p1 < "$file"
	done
	autoreconf -fsi
	cp -r ../Python ../Python-native
	touch .patched
fi

cd ../Python-native

if [ ! -f .built_native ]; then
	LDFLAGS=" -Wl,--enable-new-dtags" \
	./configure \
	--prefix=$SRC/python3/native3 \
	--without-ensurepip \
	--without-cxx-main \
	--disable-sqlite3 \
	--disable-tk \
	--with-expat=system \
	--disable-curses \
	--disable-codecs-cjk \
	--disable-nis \
	--enable-unicodedata \
	--disable-test-modules \
	--disable-idle3 \
	--disable-ossaudiodev \
	--disable-openssl \
	ac_cv_prog_HAS_HG=/bin/false
	$MAKE
	$MAKE1 install
	touch .built_native
fi

cd ../Python

if [ ! -f .patched2 ]; then
	if [ "$DESTARCHLIBC" == "musl" ];then
		sed -i 's,\/mmc,'"$PREFIX"',g' $PATCHES/python3/musl/musl-find_library.patch
		patch -p1 < $PATCHES/python3/musl/detect-host-os.patch
		patch -p1 < $PATCHES/python3/musl/musl-find_library.patch
	fi
	touch .patched2
fi

if [ ! -f .configured ]; then
	PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig \
	PATH=$SRC/python3/native3/bin:$PATH \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--build=x86_64-linux-gnu \
	--without-ensurepip \
	--with-openssl=$DEST \
	--with-system-ffi \
	--enable-shared \
	--disable-pydoc \
	--disable-test-modules \
	--disable-nis \
	--disable-idle3 \
	--enable-optimizations \
	--with-build-python=$SRC/python3/native3/bin/python3 \
	ac_cv_little_endian_double=yes \
	ac_cv_have_long_long_format=yes \
	ac_cv_file__dev_ptmx=yes \
	ac_cv_file__dev_ptc=yes \
	ac_cv_working_tzset=yes \
	ac_cv_prog_HAS_HG=/bin/false \
	ac_cv_func_wcsftime=no
	touch .configured
fi

if [ ! -f .built ]; then
	PATH=$SRC/python3/native3/bin:$PATH \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	PATH=$SRC/python3/native3/bin:$PATH \
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# UNRAR # ###################################################################
######### ###################################################################
Status "compiling unrar"

UNRAR_VERSION=6.2.2

cd $SRC/unrar

if [ ! -f .extracted ]; then
	rm -rf unrar
	tar zxvf unrarsrc-${UNRAR_VERSION}.tar.gz
	touch .extracted
fi

cd unrar

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/unrar/unrar.patch
	touch .patched
fi

if [ ! -f .built ]; then
	EABI=$EABI \
	_LDFLAGS=$LDFLAGS \
	$MAKE1
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$DEST
	cp $SRC/unrar/unrar.1 $DEST/man/man1
	touch .installed
fi

####### #####################################################################
# GIT # #####################################################################
####### #####################################################################
Status "compiling git"

GIT_VERSION=2.38.1

cd $SRC/git

if [ ! -f .extracted ]; then
	rm -rf git git-${GIT_VERSION}
	tar xvJf git-${GIT_VERSION}.tar.xz
	mv git-${GIT_VERSION} git
	touch .extracted
fi

cd git

if [ "$DESTARCHLIBC" == "musl" ];then
	gitextraconfig="NO_REGEX=NeedsStartEnd"
fi

if [ ! -f .built ]; then
	$MAKE1 distclean
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE \
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	AR=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-ar \
	prefix=$PREFIX \
	FREAD_READS_DIRECTORIES=no \
	SNPRINTF_RETURNS_BOGUS=no \
	NO_TCLTK=yes \
	NO_R_TO_GCC_LINKER=yes \
	USE_LIBPCRE2=yes \
	LIBC_CONTAINS_LIBINTL=yes \
	CURLDIR=$DEST \
	CURL_LDFLAGS=-lcurl \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -lpcre2-8 -lzstd" \
	$gitextraconfig
	touch .built
fi

if [ ! -f .installed ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE1 \
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	AR=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-ar \
	prefix=$PREFIX \
	FREAD_READS_DIRECTORIES=no \
	SNPRINTF_RETURNS_BOGUS=no \
	NO_TCLTK=yes \
	NO_R_TO_GCC_LINKER=yes \
	USE_LIBPCRE2=yes \
	LIBC_CONTAINS_LIBINTL=yes \
	CURLDIR=$DEST \
	CURL_LDFLAGS=-lcurl \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -lpcre2-8 -lzstd" \
	$gitextraconfig \
	install DESTDIR=$BASE
	tar xvJf $SRC/git/git-manpages-${GIT_VERSION}.tar.xz -C $DEST/man
	touch .installed
fi

########## ##################################################################
# STRACE # ##################################################################
########## ##################################################################
Status "compiling strace"

STRACE_VERSION=4.21

cd $SRC/strace

if [ ! -f .extracted ]; then
	rm -rf strace strace-${STRACE_VERSION}
	tar xvJf strace-${STRACE_VERSION}.tar.xz
	mv strace-${STRACE_VERSION} strace
	touch .extracted
fi

cd strace

if [ "$DESTARCH" == "mipsel" ];then
	straceconfig=ac_cv_header_linux_dm_ioctl_h=no
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	$straceconfig \
	--enable-mpers=check
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# PAM # #####################################################################
####### #####################################################################
Status "compiling pam"

LINUX_PAM_VERSION=1.5.2

cd $SRC/pam

if [ ! -f .extracted ]; then
	rm -rf Linux-PAM Linux-PAM-${LINUX_PAM_VERSION}
	tar xvJf Linux-PAM-${LINUX_PAM_VERSION}.tar.xz
	mv Linux-PAM-${LINUX_PAM_VERSION} Linux-PAM
	touch .extracted
fi

cd Linux-PAM

if [ ! -f .patched ]; then
	find libpam -iname \*.h -exec sed -i 's,\/etc\/pam,'"$PREFIX"'\/etc\/pam,g' {} \;
	if [ "$DESTARCH" == "mipsel" ] || [ "$DESTARCH" == "arm" ]; then
		patch -p1 < $PATCHES/pam/PR_SET_NO_NEW_PRIVS_OLD_KERNEL.PATCH
	fi
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-rpath \
	--enable-read-both-confs \
	--disable-nls \
	ac_cv_search_crypt=no \
	ac_cv_func_quotactl=no
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	sed -i 's,mkdir -p $(namespaceddir),mkdir -p $(DESTDIR)$(namespaceddir),g' \
	modules/pam_namespace/Makefile
	$MAKE1 install DESTDIR=$BASE
	cp -r libpam/include/security/ $DEST/include
	touch .installed
fi

########### #################################################################
# OPENSSH # #################################################################
########### #################################################################
Status "compiling openssh"

OPENSSH_VERSION=9.1p1

cd $SRC/openssh

if [ ! -f .extracted ]; then
	rm -rf openssh openssh-${OPENSSH_VERSION}
	tar zxvf openssh-${OPENSSH_VERSION}.tar.gz
	mv openssh-${OPENSSH_VERSION} openssh
	touch .extracted
fi

cd openssh

if [ ! -f .patched ] && [ "$DESTARCHLIBC" == "uclibc" ]; then
	patch -p1 < $PATCHES/openssh/openssh-fix-pam-uclibc-pthreads-clash.patch
	patch -p1 < $PATCHES/openssh/remove_check-config.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-rpath \
	--with-ssl-dir=$DEST \
	--sysconfdir=$PREFIX/etc/ssh \
	--with-pid-dir=/var/run \
	--with-privsep-path=/var/empty \
	--with-pam
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 \
	install \
	DESTDIR=$BASE \
	STRIP_OPT="-s --strip-program=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-strip"
	touch .installed
fi

######## ####################################################################
# HTOP # ####################################################################
######## ####################################################################
Status "compiling htop"

HTOP_VERSION=3.2.1

cd $SRC/htop

if [ ! -f .extracted ]; then
	rm -rf htop htop-${HTOP_VERSION}
	tar xvJf htop-${HTOP_VERSION}.tar.xz
	mv htop-${HTOP_VERSION} htop
	touch .extracted
fi

cd htop

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# SCREEN # ##################################################################
########## ##################################################################
Status "compiling screen"

SCREEN_VERSION=4.9.0

cd $SRC/screen

if [ ! -f .extracted ]; then
	rm -rf screen screen-${SCREEN_VERSION}
	tar zxvf screen-${SCREEN_VERSION}.tar.gz
	mv screen-${SCREEN_VERSION} screen
	touch .extracted
fi

cd screen

if [ ! -f .patched ]; then
	for file in $PATCHES/screen/*.patch
	do
		patch -p1 < "$file"
	done
	autoreconf -fsi
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-colors256
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# BASH # ####################################################################
######## ####################################################################
Status "compiling bash"

BASH_VERSION=5.2.9

cd $SRC/bash

if [ ! -f .extracted ]; then
	rm -rf bash bash-${BASH_VERSION}
	tar zxvf bash-${BASH_VERSION}.tar.gz
	mv bash-${BASH_VERSION} bash
	touch .extracted
fi

cd bash

if [ ! -f .patched ] && [ "$DESTARCHLIBC" == "uclibc" ]; then
	patch < $PATCHES/bash/002-force-internal-readline.patch
	patch -p1 < $PATCHES/bash/bash-random.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-rpath \
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
	bash_cv_getenv_redef=no \
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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .symlinked ]; then
	ln -sf bash $DEST/bin/sh
	touch .symlinked
fi

####### #####################################################################
# ZSH # #####################################################################
####### #####################################################################
Status "compiling zsh"

ZSH_VERSION=5.9

cd $SRC/zsh

if [ ! -f .extracted ]; then
	rm -rf zsh zsh-${ZSH_VERSION}
	tar xvJf zsh-${ZSH_VERSION}.tar.xz
	mv zsh-${ZSH_VERSION} zsh
	touch .extracted
fi

cd zsh

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# VIM # #####################################################################
####### #####################################################################
Status "compiling vim"

VIM_VERSION=9.0
M=${VIM_VERSION%.*}
m=${VIM_VERSION#*.}

cd $SRC/vim

if [ ! -f .extracted ]; then
	rm -rf vim vim$M$m
	tar xvjf vim-${VIM_VERSION}.tar.bz2
	mv vim$M$m vim
	touch .extracted
fi

cd vim

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
	vim_cv_tty_mode=0620 \
	vim_cv_getcwd_broken=no \
	vim_cv_stat_ignores_slash=yes \
	vim_cv_memmove_handles_overlap=yes \
	ac_cv_sizeof_int=4 \
	ac_cv_small_wchar_t=no
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 \
	install \
	DESTDIR=$BASE \
	STRIP=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-strip
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
Status "compiling tmux"

TMUX_VERSION=3.3a

cd $SRC/tmux

if [ ! -f .extracted ]; then
	rm -rf tmux tmux-${TMUX_VERSION}
	tar zxvf tmux-${TMUX_VERSION}.tar.gz
	mv tmux-${TMUX_VERSION} tmux
	touch .extracted
fi

cd tmux

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# UNZIP # ###################################################################
######### ###################################################################
Status "compiling unzip"

UNZIP_VERSION=60
UNZIP_PATCH_VERSION=6.0-26

cd $SRC/unzip

if [ ! -f .extracted ]; then
	rm -rf unzip unzip${UNZIP_VERSION} debian
	tar zxvf unzip${UNZIP_VERSION}.tar.gz
	tar xvJf unzip_${UNZIP_PATCH_VERSION}.debian.tar.xz
	mv unzip${UNZIP_VERSION} unzip
	touch .extracted
fi

cd unzip

if [ ! -f .patched ]; then
	if [[ ! ("$DESTARCH" == "arm" && "$DESTARCHLIBC" == "musl") ]]; then
		for file in $SRC/unzip/debian/patches/*.patch
		do
			patch -p1 < "$file"
		done
	fi
	patch -p1 < $PATCHES/unzip/0001-Add-a-CMakeFile.txt-to-ease-cross-compilation.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	cmake \
	-GNinja \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_C_COMPILER=`which $DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc` \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	./
fi

if [ ! -f .built ]; then
	$NINJA
	touch .built
fi

if [ ! -f .installed ]; then
	DESTDIR=$BASE $NINJA install
	touch .installed
fi

######## ####################################################################
# GZIP # ####################################################################
######## ####################################################################
Status "compiling gzip"

GZIP_VERSION=1.12

cd $SRC/gzip

if [ ! -f .extracted ]; then
	rm -rf gzip gzip-${GZIP_VERSION}
	tar xvJf gzip-${GZIP_VERSION}.tar.xz
	mv gzip-${GZIP_VERSION} gzip
	touch .extracted
fi

cd gzip

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# BOOST  # ##################################################################
########## ##################################################################
Status "compiling boost"

BOOST_VERSION=1_80_0

cd $SRC/boost

if [ ! -f .extracted ]; then
	rm -rf boost boost_${BOOST_VERSION} build
	tar xvJf boost_${BOOST_VERSION}.tar.xz
	mv boost_${BOOST_VERSION} boost
	mkdir -p $SRC/boost/build
	touch .extracted
fi

cd boost

if [ ! -f .patched ] && [ "$DESTARCHLIBC" == "uclibc" ]; then
	patch -p1 < $PATCHES/boost/0001-fenv.patch
	touch .patched
fi

if [ "$DESTARCH" == "arm" ];then
	BOOST_ABI=aapcs
else
	BOOST_ABI=sysv
fi

if ! [[ -f .configured ]]; then
	echo  "using gcc : $DESTARCH : $DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++ ;" > $SRC/boost/user-config.jam
	./bootstrap.sh
	touch .configured
fi

if ! [[ -f .built ]]; then
	HOME=$SRC/boost \
	./b2 \
	-q \
	--prefix=$DEST \
	--build-dir=$SRC/boost/build \
	--without-python \
	boost.locale.posix=off \
	toolset=gcc-$DESTARCH \
	threading=multi \
	abi=$BOOST_ABI \
	variant=release \
	cxxflags="-Wno-narrowing $CXXFLAGS" \
	-j`nproc` \
	-sBZIP2_INCLUDE=$DEST/include \
	-sBZIP2_LIBPATH=$DEST/lib \
	-sZLIB_INCLUDE=$DEST/include \
	-sZLIB_LIBPATH=$DEST/lib \
	-sLZMA_INCLUDE=$DEST/include \
	-sLZMA_LIBPATH=$DEST/lib \
	-sZSTD_INCLUDE=$DEST/include \
	-sZSTD_LIBPATH=$DEST/lib \
	install
	touch .built
fi

########### #################################################################
# LIBEDIT # #################################################################
########### #################################################################
Status "compiling libedit"

LIBEDIT_VERSION=20221030-3.1

cd $SRC/libedit

if [ ! -f .extracted ]; then
	rm -rf libedit libedit-${LIBEDIT_VERSION}
	tar zxvf libedit-${LIBEDIT_VERSION}.tar.gz
	mv libedit-${LIBEDIT_VERSION} libedit
	touch .extracted
fi

cd libedit

if [ ! -f .patched ] && [ "$DESTARCHLIBC" == "uclibc" ]; then
	patch -p1 < $PATCHES/libedit/libedit-uclibc.patch
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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

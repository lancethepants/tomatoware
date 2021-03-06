#!/bin/bash

source ./scripts/environment.sh

######### ###################################################################
# BZIP2 # ###################################################################
######### ###################################################################
Status "bzip2"

BZIP2_VERSION=1.0.8

cd $SRC/bzip2

if [ ! -f .extracted ]; then
	rm -rf bzip2-${BZIP2_VERSION}
	tar zxvf bzip2-${BZIP2_VERSION}.tar.gz
	touch .extracted
fi

cd bzip2-${BZIP2_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/bzip2/bzip2.patch
	patch -p1 < $PATCHES/bzip2/bzip2_so.patch
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
Status "zlib"

ZLIB_VERSION=1.2.11

cd $SRC/zlib

if [ ! -f .extracted ]; then
	rm -rf zlib-${ZLIB_VERSION}
	tar xvJf zlib-${ZLIB_VERSION}.tar.xz
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
Status "lzo"

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

####### #####################################################################
# LZ4 # #####################################################################
####### #####################################################################
Status "lz4"

LZ4_VERSION=1.9.3

cd $SRC/lz4

if [ ! -f .extracted ]; then
        rm -rf lz4-${LZ4_VERSION}
        tar zxvf lz4-${LZ4_VERSION}.tar.gz
        touch .extracted
fi

cd lz4-${LZ4_VERSION}

if [ ! -f .built ]; then
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	PREFIX=$PREFIX \
        LDFLAGS=$LDFLAGS \
        CPPFLAGS=$CPPFLAGS \
        CFLAGS=$CFLAGS \
        CXXFLAGS=$CXXFLAGS \
        $MAKE
        touch .built
fi

if [ ! -f .installed ]; then
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	PREFIX=$PREFIX \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	make install DESTDIR=$BASE
        touch .installed
fi

############ ################################################################
# XZ UTILS # ################################################################
############ ################################################################
Status "xz utils"

XZ_UTILS_VERSION=5.2.5

cd $SRC/xz

if [ ! -f .extracted ]; then
	rm -rf xz-${XZ_UTILS_VERSION}
	tar xvJf xz-${XZ_UTILS_VERSION}.tar.xz
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

######## ####################################################################
# ZSTD # ####################################################################
######## ####################################################################
Status "zstd"

ZSTD_VERSION=1.5.0

cd $SRC/zstd

if [ ! -f .extracted ]; then
	rm -rf zstd-${ZSTD_VERSION}
	tar zxvf zstd-${ZSTD_VERSION}.tar.gz
	touch .extracted
fi

cd zstd-${ZSTD_VERSION}

if [ ! -f .built ]; then
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	PREFIX=$PREFIX \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	PREFIX=$PREFIX \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	make install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################
Status "openssl"

OPENSSL_VERSION=1.1.1k

cd $SRC/openssl

if [ ! -f .extracted ]; then
	rm -rf openssl-${OPENSSL_VERSION}
	tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
	touch .extracted
fi

cd openssl-${OPENSSL_VERSION}

# Patch taken from openwrt.
# Neither current arm or mipsel routers have aes hardware acceleration.
# If we ever get aarch64 support we may want to disable this for those devices.
if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/openssl/140-allow-prefer-chacha20.patch
	touch .patched
fi

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
	--with-zlib-include=$DEST/include \
	-DOPENSSL_PREFER_CHACHA_OVER_GCM
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

######## ####################################################################
# FLEX # ####################################################################
######## ####################################################################
Status "flex"

FLEX_VERSION=2.6.0

cd $SRC/flex

if [ ! -f .extracted ]; then
	rm -rf flex-${FLEX_VERSION}
	tar xvJf flex-${FLEX_VERSION}.tar.xz
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
Status "curl"

CURL_VERSION=7.77.0

cd $SRC/curl

if [ ! -f .extracted ]; then
	rm -rf curl-${CURL_VERSION}
	tar xvJf curl-${CURL_VERSION}.tar.xz
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

######### ###################################################################
# CERTS # ###################################################################
######### ###################################################################
Status "certs"

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
Status "expat"

EXPAT_VERSION=2.4.1

cd $SRC/expat

if [ ! -f .extracted ]; then
	rm -rf cd expat-${EXPAT_VERSION}
	tar xvJf expat-${EXPAT_VERSION}.tar.xz
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
Status "libpcap"

LIBPCAP_VERSION=1.10.1

cd $SRC/libpcap

if [ ! -f .extracted ]; then
	rm -rf libpcap-${LIBPCAP_VERSION}
	tar zxvf libpcap-${LIBPCAP_VERSION}.tar.gz
	touch .extracted
fi

cd libpcap-${LIBPCAP_VERSION}

if [ ! -f .patched ]; then
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
	make install DESTDIR=$BASE
	touch .installed
fi

########## ##################################################################
# LIBFFI # ##################################################################
########## ##################################################################
Status "libffi"

LIBFFI_VERSION=3.4.2

cd $SRC/libffi

if [ ! -f .extracted ]; then
	rm -rf libffi-${LIBFFI_VERSION}
	tar zxvf libffi-${LIBFFI_VERSION}.tar.gz
	touch .extracted
fi

cd libffi-${LIBFFI_VERSION}

if [ ! -f .patched ] && [ "$DESTARCH" == "mipsel" ]; then
	patch -p1 < $PATCHES/libffi/0002-Fix-use-of-compact-eh-frames-on-MIPS.patch
	patch -p1 < $PATCHES/libffi/0003-libffi-enable-hardfloat-in-the-MIPS-assembly-code.patch
	autoreconf
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
Status "ncurses"

NCURSES_VERSION=6.2
M=${NCURSES_VERSION%.*}
m=${NCURSES_VERSION#*.}

cd $SRC/ncurses

if [ ! -f .extracted ]; then
	rm -rf ncurses-${NCURSES_VERSION} ncurses-${NCURSES_VERSION}-native
	tar zxvf ncurses-${NCURSES_VERSION}.tar.gz
	cp -r ncurses-${NCURSES_VERSION} ncurses-${NCURSES_VERSION}-native
	touch .extracted
fi

cd ncurses-${NCURSES_VERSION}-native

if [ ! -f .built-native ]; then
	./configure \
	--prefix=$SRC/ncurses/ncurses-${NCURSES_VERSION}-native/install \
	--without-cxx \
	--without-cxx-binding \
	--without-ada \
	--without-debug \
	--without-manpages \
	--without-profile \
	--without-tests \
	--without-curses-h
	$MAKE
	make install
	touch .built-native
fi

cd ../ncurses-${NCURSES_VERSION}

if [ ! -f .configured ]; then
	PATH=$SRC/ncurses/ncurses-${NCURSES_VERSION}-native/install/bin:$PATH \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
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
	PATH=$SRC/ncurses/ncurses-${NCURSES_VERSION}-native/install/bin:$PATH \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	PATH=$SRC/ncurses/ncurses-${NCURSES_VERSION}-native/install/bin:$PATH \
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .linked ]; then
	ln -sf libncursesw.a $DEST/lib/libncurses.a
	ln -sf libncursesw.so $DEST/lib/libncurses.so
	ln -sf libncursesw.so.$M $DEST/lib/libncurses.so.$M
	ln -sf libncursesw.so.$M.$m $DEST/lib/libncurses.so.$M.$m
	ln -sf libncurses++w.a $DEST/lib/libncurses++.a
	ln -sf libncursesw_g.a $DEST/lib/libncurses_g.a
	ln -sf libncursesw.a $DEST/lib/libcurses.a
	ln -sf libncursesw.so $DEST/lib/libcurses.so
	ln -sf libcurses.so $DEST/lib/libtinfo.so

	ln -sf libpanelw.a $DEST/lib/libpanel.a
	ln -sf libpanelw.so $DEST/lib/libpanel.so
	ln -sf libpanelw.so.$M $DEST/lib/libpanel.so.$M
	ln -sf libpanelw.so.$M.$m $DEST/lib/libpanel.so.$M.$m
	ln -sf libpanelw_g.a $DEST/lib/libpanel_g.a

	ln -sf libmenuw.a $DEST/lib/libmenu.a
	ln -sf libmenuw.so $DEST/lib/libmenu.so
	ln -sf libmenuw.so.$M $DEST/lib/libmenu.so.$M
	ln -sf libmenuw.so.$M.$m $DEST/lib/libmenu.so.$M.$m
	ln -sf libmenuw_g.a $DEST/lib/libmenu_g.a

	touch .linked
fi

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################
Status "libreadline"

LIBREADLINE_VERSION=8.1

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

####### #####################################################################
# LUA # #####################################################################
####### #####################################################################
Status "lua"

LUA_VERSION=5.4.3

cd $SRC/lua

if [ ! -f .extracted ]; then
	rm -rf lua-${LUA_VERSION}
	tar zxvf lua-${LUA_VERSION}.tar.gz
	touch .extracted
fi

cd lua-${LUA_VERSION}

if [ ! -f .built ]; then
	make \
	linux \
	CC=$DESTARCH-linux-gcc \
	INSTALL_TOP=$BASE$PREFIX \
	MYCFLAGS="$CFLAGS $CPPFLAGS" \
	MYLDFLAGS="$LDFLAGS"
	touch .built
fi

if [ ! -f .installed ]; then
	make \
	linux \
	CC=$DESTARCH-linux-gcc \
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
Status "libgdbm"

LIBGDBM_VERSION=1.20

cd $SRC/libgdbm

if [ ! -f .extracted ]; then
	rm -rf gdbm-${LIBGDBM_VERSION}
	tar zxvf gdbm-${LIBGDBM_VERSION}.tar.gz
	touch .extracted
fi

cd gdbm-${LIBGDBM_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/libgdbm/libgdbm.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS -fcommon" \
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
Status "tcl"

TCL_VERSION=8.6.11

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
Status "bdb"

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
Status "sqlite"

SQLITE_VERSION=3360000

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

########### #################################################################
# LIBXML2 # #################################################################
########### #################################################################
Status "libxml2"

LIBXML2_VERSION=2.9.12

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
Status "libxslt"

LIBXSLT_VERSION=1.1.34

cd $SRC/libxslt

if [ ! -f .extracted ]; then
	rm -rf libxslt-${LIBXSLT_VERSION}
	tar zxvf libxslt-${LIBXSLT_VERSION}.tar.gz
	touch .extracted
fi

cd libxslt-${LIBXSLT_VERSION}

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
	make install DESTDIR=$BASE
	touch .installed
fi

############# ###############################################################
# LIBSIGC++ # ###############################################################
############# ###############################################################
Status "libsigc++"

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
Status "libpar2"

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
Status "libevent"

LIBEVENT_VERSION=2.1.12

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
Status "libmysqlclient"

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
Status "perl"

PERL_CROSS_VERSION=1.3.6

cd $SRC/perl

if [ ! -f .extracted ]; then
	rm -rf perl-${PERL_VERSION} perl-${PERL_VERSION}_host native
	tar zxvf perl-${PERL_VERSION}.tar.gz
	tar zxvf perl-cross-${PERL_CROSS_VERSION}.tar.gz -C perl-${PERL_VERSION} --strip 1
	cp -r perl-${PERL_VERSION} perl-${PERL_VERSION}_host
	touch .extracted
fi

cd perl-${PERL_VERSION}_host

if [ ! -f .configured ]; then
	./configure \
	--prefix=$SRC/perl/native
	$MAKE
	make install
	touch .configured
fi

cd ../perl-${PERL_VERSION}

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
Status "pcre"

PCRE_VERSION=8.45

cd $SRC/pcre

if [ ! -f .extracted ]; then
	rm -rf pcre-${PCRE_VERSION}
	tar xvjf pcre-${PCRE_VERSION}.tar.bz2
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

######### ###################################################################
# PCRE2 # ###################################################################
######### ###################################################################
Status "pcre2"

PCRE2_VERSION=10.37

cd $SRC/pcre2

if [ ! -f .extracted ]; then
	rm -rf pcre2-${PCRE2_VERSION}
	tar xvjf pcre2-${PCRE2_VERSION}.tar.bz2
	touch .extracted
fi

cd pcre2-${PCRE2_VERSION}

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
	make install DESTDIR=$BASE
	touch .installed
fi

############### #############################################################
# PAR2CMDLINE # #############################################################
############### #############################################################
Status "par2cmdline"

PAR2CMDLINE_VERSION=0.8.1

cd $SRC/par2cmdline

if [ ! -f .extracted ]; then
	rm -rf par2cmdline-${PAR2CMDLINE_VERSION}
	tar xvjf par2cmdline-${PAR2CMDLINE_VERSION}.tar.bz2
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

########## ##################################################################
# PYTHON # ##################################################################
########## ##################################################################
Status "python"

PYTHON_VERSION=2.7.18

cd $SRC/python

if [ ! -f .extracted ]; then
	rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}-native native
	tar xvJf Python-${PYTHON_VERSION}.tar.xz
	touch .extracted
fi

cd Python-${PYTHON_VERSION}

if [ ! -f .patched ]; then
	for file in $PATCHES/python/*.patch
	do
		patch -p1 < "$file"
	done
	autoreconf
	cp -r ../Python-${PYTHON_VERSION} ../Python-${PYTHON_VERSION}-native
	touch .patched
fi

cd ../Python-${PYTHON_VERSION}-native

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
        make
        make install
        touch .built_native
fi

cd ../Python-${PYTHON_VERSION}

if [ ! -f .configured ]; then
	PATH=$SRC/python/native/bin:$PATH \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure \
	--prefix=$PREFIX \
	--host=$DESTARCH-linux \
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
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f $DEST/bin/python ]; then
        ln -s python2 $DEST/bin/python
fi

########### #################################################################
# PYTHON3 # #################################################################
########### #################################################################
Status "python3"

PYTHON3_VERSION=3.9.6

cd $SRC/python3

if [ ! -f .extracted ]; then
	rm -rf Python-${PYTHON3_VERSION} Python-${PYTHON3_VERSION}-native native3
	tar xvJf Python-${PYTHON3_VERSION}.tar.xz
	touch .extracted
fi

cd Python-${PYTHON3_VERSION}

if [ ! -f .patched ]; then
	for file in $PATCHES/python3/*.patch
	do
		patch -p1 < "$file"
	done
	autoreconf
	cp -r ../Python-${PYTHON3_VERSION} ../Python-${PYTHON3_VERSION}-native
	touch .patched
fi

cd ../Python-${PYTHON3_VERSION}-native

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
	make
	make install
	touch .built_native
fi

cd ../Python-${PYTHON3_VERSION}

if [ ! -f .configured ]; then
	PATH=$SRC/python3/native3/bin:$PATH \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure \
	--prefix=$PREFIX \
	--host=$DESTARCH-linux \
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
	make install DESTDIR=$BASE
	touch .installed
fi

######### ###################################################################
# UNRAR # ###################################################################
######### ###################################################################
Status "unrar"

UNRAR_VERSION=6.0.7

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
	make
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$DEST
	cp $SRC/unrar/unrar.1 $DEST/man/man1
	touch .installed
fi

####### #####################################################################
# GIT # #####################################################################
####### #####################################################################
Status "git"

GIT_VERSION=2.32.0

cd $SRC/git

if [ ! -f .extracted ]; then
	rm -rf git-${GIT_VERSION}
	tar xvJf git-${GIT_VERSION}.tar.xz
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
	USE_LIBPCRE2=yes \
	LIBC_CONTAINS_LIBINTL=yes \
	CURLDIR=$DEST \
	CURL_LDFLAGS=-lcurl \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -lpcre2-8"
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
	USE_LIBPCRE2=yes \
	LIBC_CONTAINS_LIBINTL=yes \
	CURLDIR=$DEST \
	CURL_LDFLAGS=-lcurl \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -lpcre2-8" \
	install DESTDIR=$BASE
	tar xvJf $SRC/git/git-manpages-${GIT_VERSION}.tar.xz -C $DEST/man
	touch .installed
fi

########## ##################################################################
# STRACE # ##################################################################
########## ##################################################################
Status "strace"

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
Status "pam"

LINUX_PAM_VERSION=1.3.0

cd $SRC/pam

if [ ! -f .extracted ]; then
	rm -rf Linux-PAM-${LINUX_PAM_VERSION}
	tar xvjf Linux-PAM-${LINUX_PAM_VERSION}.tar.bz2
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
Status "openssh"

OPENSSH_VERSION=8.6p1

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
Status "htop"

HTOP_VERSION=3.0.5

cd $SRC/htop

if [ ! -f .extracted ]; then
	rm -rf htop-${HTOP_VERSION}
	tar zxvf htop-${HTOP_VERSION}.tar.gz
	touch .extracted
fi

cd htop-${HTOP_VERSION}

if [ ! -f .patched ] && [ "$DESTARCH" == "mipsel" ]; then
	patch -p1 < $PATCHES/htop/htop-mipsel-no-SELINUX_MAGIC.patch
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS -fcommon" \
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
Status "screen"

SCREEN_VERSION=4.8.0

cd $SRC/screen

if [ ! -f .extracted ]; then
	rm -rf screen-${SCREEN_VERSION}
	tar zxvf screen-${SCREEN_VERSION}.tar.gz
	touch .extracted
fi

cd screen-${SCREEN_VERSION}

if [ ! -f .patched ]; then
	for file in $PATCHES/screen/*.patch
	do
		patch -p1 < "$file"
	done
	autoreconf
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
	make install DESTDIR=$BASE
	touch .installed
fi

######## ####################################################################
# BASH # ####################################################################
######## ####################################################################
Status "bash"

BASH_VERSION=5.1.8

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
	patch -p1 < $PATCHES/bash/bash-random.patch
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
	make install DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# ZSH # #####################################################################
####### #####################################################################
Status "zsh"

ZSH_VERSION=5.8

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
Status "vim"

VIM_VERSION=8.2

cd $SRC/vim

if [ ! -f .extracted ]; then
	rm -rf vim81
	tar xvjf vim-${VIM_VERSION}.tar.bz2
	touch .extracted
fi

cd vim82

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
Status "tmux"

TMUX_VERSION=3.2a

cd $SRC/tmux

if [ ! -f .extracted ]; then
	rm -rf tmux-${TMUX_VERSION}
	tar zxvf tmux-${TMUX_VERSION}.tar.gz
	touch .extracted
fi

cd tmux-${TMUX_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/tmux/100-add-crosscompiling-fallbacks.patch
	autoreconf
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

######### ###################################################################
# UNZIP # ###################################################################
######### ###################################################################
Status "unzip"

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
Status "gzip"

GZIP_VERSION=1.10

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
Status "boost"

BOOST_VERSION=1_76_0

cd $SRC/boost

if [ ! -f .extracted ]; then
	rm -rf boost_${BOOST_VERSION} build
	tar xvJf boost_${BOOST_VERSION}.tar.xz
	mkdir -p $SRC/boost/build
	touch .extracted
fi

cd boost_${BOOST_VERSION}

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/boost/0001-fenv.patch
	touch .patched
fi

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
	-sZSTD_INCLUDE=$DEST/include \
	-sZSTD_LIBPATH=$DEST/lib \
	install \
	|| true
	touch .built
fi

########### #################################################################
# LIBEDIT # #################################################################
########### #################################################################
Status "libedit"

LIBEDIT_VERSION=20210522-3.1

cd $SRC/libedit

if [ ! -f .extracted ]; then
	rm -rf libedit-${LIBEDIT_VERSION}
	tar zxvf libedit-${LIBEDIT_VERSION}.tar.gz
	touch .extracted
fi

cd libedit-${LIBEDIT_VERSION}

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

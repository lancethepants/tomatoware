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

########## ##################################################################
# NETTLE # ##################################################################
########## ##################################################################

NETTLE_VERSION=3.4

cd $SRC/nettle

if [ ! -f .extracted ]; then
	rm -rf nettle-${NETTLE_VERSION}
	tar zxvf nettle-${NETTLE_VERSION}.tar.gz
	touch .extracted
fi

cd nettle-${NETTLE_VERSION}

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
# GNUTLS # ##################################################################
########## ##################################################################

GNUTLS_VERSION=3.6.3

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/gnutls

if [ ! -f .extracted ]; then
	rm -rf gnutls-${GNUTLS_VERSION}
	tar xvJf gnutls-${GNUTLS_VERSION}.tar.xz
	touch .extracted
fi

cd gnutls-${GNUTLS_VERSION}

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-local-libopts \
	--without-p11-kit \
	--with-included-libtasn1 \
	--enable-static \
	--disable-doc \
	--with-included-unistring
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

if [ ! -f .installed_binary ]; then
	cp ../libgnutls-config $DEST/bin        
	touch .installed_binary
fi

unset PKG_CONFIG_LIBDIR

if [ ! -f .edit_sed ]; then

	sed -i 's,'"$PREFIX"'\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
	$DEST/lib/libgnutls.la

	sed -i 's,'"$PREFIX"'\/lib\/libintl.la,'"$DEST"'\/lib\/libintl.la,g' \
	$DEST/lib/libgnutls.la

	sed -i 's,'"$PREFIX"'\/lib\/libgmp.la,'"$DEST"'\/lib\/libgmp.la,g' \
	$DEST/lib/libgnutls.la

	touch .edit_sed
fi

########### #################################################################
# IKSEMEL # #################################################################
########### #################################################################

IKSEMEL_VERSION=1.5

export PKG_CONFIG_PATH=$DEST/lib/pkgconfig

cd $SRC/iksemel

if [ ! -f .extracted ]; then
	rm -rf iksemel-${IKSEMEL_VERSION}
	tar zxvf iksemel-${IKSEMEL_VERSION}.tar.gz
	touch .extracted
fi

cd iksemel-${IKSEMEL_VERSION}

if [ ! -f .configured ]; then
	./autogen.sh
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-gnutls \
	--disable-python
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

unset PKG_CONFIG_PATH

######## ####################################################################
# SRTP # ####################################################################
######## ####################################################################

SRTP_VERSION=2.2.0

cd $SRC/srtp

if [ ! -f .extracted ]; then
	rm -rf libsrtp-${SRTP_VERSION}
	tar zxvf libsrtp-${SRTP_VERSION}.tar.gz
	touch .extracted
fi

cd libsrtp-${SRTP_VERSION}

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
# unixODBC # ################################################################
############ ################################################################

UNIXODBC_VERSION=2.3.7

cd $SRC/odbc

if [ ! -f .extracted ]; then
	rm -rf unixODBC-${UNIXODBC_VERSION}
	tar zxvf unixODBC-${UNIXODBC_VERSION}.tar.gz
	touch .extracted
fi

cd unixODBC-${UNIXODBC_VERSION}

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
# JANSSON # #################################################################
########### #################################################################

JANSSON_VERSION=2.11

cd $SRC/jansson

if [ ! -f .extracted ]; then
	rm -rf jansson-${JANSSON_VERSION}
	tar xvjf jansson-${JANSSON_VERSION}.tar.bz2
	touch .extracted
fi

cd jansson-${JANSSON_VERSION}

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
# ASTERISK # ################################################################
############ ################################################################

ASTERISK_VERSION=13.20.0

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/asterisk

if [ ! -f .extracted ]; then
	rm -rf asterisk-${ASTERISK_VERSION}
	tar zxvf asterisk-${ASTERISK_VERSION}.tar.gz
	touch .extracted
fi

cd asterisk-${ASTERISK_VERSION}

if [ ! -f .patched ]; then
	patch < $PATCHES/asterisk/010-asterisk-configure-undef-res-ninit.patch
	sed -i 's,\/etc\/localtime,'"$PREFIX"'\/etc\/localtime,g' main/stdtime/localtime.c
	touch .patched
fi

if [ "$DESTARCH" == "mipsel" ];then
	os=mipsel-buildroot-linux-uclibc
fi

if [ "$DESTARCH" == "arm" ];then
	os=arm-buildroot-linux-uclibcgnueabi
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="-I$DEST/include/libxml2 $CPPFLAGS $CFLAGS" \
	CFLAGS="-I$DEST/include/libxml2 $CPPFLAGS $CFLAGS" \
	CXXFLAGS="-I$DEST/include/libxml2 $CPPFLAGS $CFLAGS" \
	./configure --prefix=$PREFIX --host=$os \
	--without-sdl \
	--disable-xmldoc \
	--with-externals-cache=$SRC/pjsip \
	--with-pjproject-bundled \
	--with-libxml2=$DEST \
	--with-mysqlclient=$DEST \
	--with-crypto=$DEST \
	--with-iconv=$DEST \
	--with-iksemel=$DEST \
	--with-jansson=$DEST \
	--with-libcurl=$DEST \
	--with-ncurses=$DEST \
	--with-unixodbc=$DEST \
	--with-sqlite3=$DEST \
	--with-srtp=$DEST \
	--with-ssl=$DEST \
	--with-z=$DEST

	make menuselect.makeopts CC=cc CXX=g++ || true
	make menuselect.makeopts CC=cc CXX=g++
	./menuselect/menuselect --enable cdr_mysql menuselect.makeopts

	touch .configured
fi

if [ ! -f .built ]; then
	ASTLDFLAGS=$LDFLAGS \
	ASTCFLAGS="-I$DEST/include/libxml2 $CPPFLAGS $CFLAGS" \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .installed_example ]; then
	tar zxvf ../asterisk_gv.tgz -C $DEST/etc
	mkdir $DEST/etc/config
	cp ../asterisk.wanup $DEST/etc/config
	sed -i 's,\/opt,'"$PREFIX"',g' $DEST/etc/config/asterisk.wanup
	touch .installed_example
fi

unset PKG_CONFIG_LIBDIR

######################## ####################################################
# ASTERISK CHAN_DONGLE # ####################################################
######################## ####################################################

cd $SRC/asterisk

if [ ! -f .extracted_chan_dongle ]; then
	rm -rf asterisk-chan-dongle
	tar zxvf asterisk-chan-dongle.tgz
	touch .extracted_chan_dongle
fi

cd asterisk-chan-dongle

if [ ! -f .pre-configured ]; then
	patch < $PATCHES/asterisk/asterisk-chan-dongle.patch
	./bootstrap
	touch .pre-configured
fi

if [ ! -f .configured ]; then
	DEST=$DEST \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-asterisk=$DEST/include \
	--with-astversion=${ASTERISK_VERSION}
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	make install
	touch .installed
fi

###################### ######################################################
# TIME ZONE DATABASE # ######################################################
###################### ######################################################

cd $SRC/tz

if [ ! -f .extracted ]; then
	rm -rf tz tz-native
	mkdir tz
	tar zxvf tzcode2018e.tar.gz -C ./tz
	tar zxvf tzdata2018e.tar.gz -C ./tz
	cp -r tz tz-native
        touch .extracted
fi

cd tz-native

if [ ! -f .installed ]; then
        make \
        TOPDIR=$PREFIX \
        DESTDIR=$BASE
        touch .installed
fi

cd ../tz

if [ ! -f .installed ]; then
	make install \
	cc=$DESTARCH-linux-gcc \
	LFLAGS="$LDFLAGS" \
	CFLAGS="$CFLAGS" \
	TOPDIR=$PREFIX \
	USRDIR="" \
	DESTDIR=$BASE \
	zic=../tz-native/zic
	touch .installed
fi

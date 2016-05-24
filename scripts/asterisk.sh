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

cd $SRC/nettle

if [ ! -f .extracted ]; then
	rm -rf nettle-3.2
	tar zxvf nettle-3.2.tar.gz
	touch .extracted
fi

cd nettle-3.2

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

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/gnutls

if [ ! -f .extracted ]; then
	rm -rf gnutls-3.5.0
	tar xvJf gnutls-3.5.0.tar.xz
	touch .extracted
fi

cd gnutls-3.5.0

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-local-libopts \
	--without-p11-kit \
	--with-included-libtasn1 \
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

export PKG_CONFIG_PATH=$DEST/lib/pkgconfig

cd $SRC/iksemel

if [ ! -f .extracted ]; then
	rm -rf iksemel-1.5
	tar zxvf iksemel-1.5.tar.gz
	touch .extracted
fi

cd iksemel-1.5

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

cd $SRC/srtp

if [ ! -f .extracted ]; then
	rm -rf srtp
	tar zxvf srtp-1.4.4.tgz
	touch .extracted
fi

cd srtp

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/libsrtp/1003_fix_mips_namespace_collision.patch
	patch -p1 < $PATCHES/libsrtp/1005_fix_data_alignment.patch
	patch -p1 < $PATCHES/libsrtp/1007_update_Doxyfile.patch
	patch -p1 < $PATCHES/libsrtp/1008_shared-lib.patch
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

############ ################################################################
# unixODBC # ################################################################
############ ################################################################

cd $SRC/odbc

if [ ! -f .extracted ]; then
	rm -rf unixODBC-2.3.4
	tar zxvf unixODBC-2.3.4.tar.gz
	touch .extracted
fi

cd unixODBC-2.3.4

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

############ ################################################################
# ASTERISK # ################################################################
############ ################################################################

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/asterisk

if [ ! -f .extracted ]; then
	rm -rf asterisk-11.22.0
	tar zxvf asterisk-11.22.0.tar.gz
	touch .extracted
fi

cd asterisk-11.22.0

if [ ! -f .patched ]; then
	patch < $PATCHES/asterisk/010-asterisk-configure-undef-res-ninit.patch
	patch -p1 < $PATCHES/asterisk/0001-chan_sip-Support-RFC-3966-TEL-URIs-in-inbound-INVITE.patch
	sed -i 's,\/etc\/localtime,'"$PREFIX"'\/etc\/localtime,g' main/stdtime/localtime.c
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="-I$DEST/include/libxml2 $CPPFLAGS" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-sdl \
	--with-libxml2=$DEST \
	--with-mysqlclient=$DEST \
	--with-crypto=$DEST \
	--with-iconv=$DEST \
	--with-iksemel=$DEST \
	--with-libcurl=$DEST \
	--with-ncurses=$DEST \
	--with-unixodbc=$DEST \
	--with-sqlite3=$DEST \
	--with-srtp=$DEST \
	--with-ssl=$DEST \
	--with-uuid=$DEST \
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
	aclocal
	autoconf
	automake -a || true
	touch .pre-configured
fi

if [ ! -f .configured ]; then
	DEST=$DEST \
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
	tar zxvf tzcode2016d.tar.gz -C ./tz
	tar zxvf tzdata2016d.tar.gz -C ./tz
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
	DESTDIR=$BASE \
	zic=../tz-native/zic
	touch .installed
fi

#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=$BASE/src
PATCHES=$BASE/patches
RPATH=$PREFIX/lib
DEST=$BASE$PREFIX
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
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
	rm -rf nettle-2.7.1
	tar zxvf nettle-2.7.1.tar.gz
	touch .extracted
fi

cd nettle-2.7.1

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
	rm -rf gnutls-3.2.21
	tar xvJf gnutls-3.2.21.tar.xz
	touch .extracted
fi

cd gnutls-3.2.21

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-local-libopts \
	--without-p11-kit
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

cd $SRC/iksemel

if [ ! -f .extracted ]; then
	rm -rf iksemel-1.4
	tar zxvf iksemel-1.4.tar.gz
	touch .extracted
fi

cd iksemel-1.4

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-libgnutls-prefix=$DEST
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
# ASTERISK # ################################################################
############ ################################################################

cd $SRC/asterisk

if [ ! -f .extracted ]; then
	rm -rf asterisk-11.16.0
	tar zxvf asterisk-11.16.0.tar.gz
	touch .extracted
fi

cd asterisk-11.16.0

if [ ! -f .patched ]; then
	if [ "$DESTARCH" == "arm" ];then
		patch < $PATCHES/asterisk/010-asterisk-configure-undef-res-ninit.patch
	fi
	sed -i 's,\/etc\/localtime,'"$PREFIX"'\/etc\/localtime,g' main/stdtime/localtime.c
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-mysqlclient=$DEST \
	--with-crypto=$DEST \
	--with-iconv=$DEST \
	--with-iksemel=$DEST \
	--with-libcurl=$DEST \
	--with-ncurses=$DEST \
	--with-sqlite3=$DEST \
	--with-srtp=$DEST \
	--with-ssl=$DEST \
	--with-uuid=$DEST \
	--with-z=$DEST

	make menuselect.makeopts
	./menuselect/menuselect --enable cdr_mysql menuselect.makeopts

	touch .configured
fi

if [ ! -f .built ]; then
	ASTLDFLAGS=$LDFLAGS \
	ASTCFLAGS="$CPPFLAGS $CFLAGS" \
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
	git checkout asterisk11
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
	tar zxvf tzcode2015b.tar.gz -C ./tz
	tar zxvf tzdata2015b.tar.gz -C ./tz
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
	TOPDIR=$PREFIX \
	DESTDIR=$BASE \
	zic=../tz-native/zic
	touch .installed
fi

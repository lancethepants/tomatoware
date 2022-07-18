#!/bin/bash

source ./scripts/environment.sh

########## ##################################################################
# NETTLE # ##################################################################
########## ##################################################################
Status "compiling nettle"

NETTLE_VERSION=3.8

cd $SRC/nettle

if [ ! -f .extracted ]; then
	rm -rf nettle nettle-${NETTLE_VERSION}
	tar zxvf nettle-${NETTLE_VERSION}.tar.gz
	mv nettle-${NETTLE_VERSION} nettle
	touch .extracted
fi

cd nettle

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
# GNUTLS # ##################################################################
########## ##################################################################
Status "compiling gnutls"

GNUTLS_VERSION=3.7.6

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/gnutls

if [ ! -f .extracted ]; then
	rm -rf gnutls gnutls-${GNUTLS_VERSION}
	tar xvJf gnutls-${GNUTLS_VERSION}.tar.xz
	mv gnutls-${GNUTLS_VERSION} gnutls
	touch .extracted
fi

cd gnutls

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--disable-rpath \
	--with-default-trust-store-file=$PREFIX/ssl/certs/ca-certificates.crt \
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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .installed_binary ]; then
	cp ../libgnutls-config $DEST/bin
	touch .installed_binary
fi

unset PKG_CONFIG_LIBDIR

if [ ! -f .edit_sed ]; then

	sed -i 's,'"$PREFIX"'\/lib\/libgmp.la,'"$DEST"'\/lib\/libgmp.la,g' \
	$DEST/lib/libgnutls.la

	touch .edit_sed
fi

################ ############################################################
# LIBGPG-ERROR # ############################################################
################ ############################################################
Status "compiling libgpg-error"

LIBGPG_ERROR_VERSION=1.45

cd $SRC/libgpg-error

if [ ! -f .extracted ]; then
	rm -rf libgpg-error libgpg-error-${LIBGPG_ERROR_VERSION}
	tar xvjf libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2
	mv libgpg-error-${LIBGPG_ERROR_VERSION} libgpg-error
	touch .extracted
fi

cd libgpg-error

if [ "$DESTARCH" == "mipsel" ]; then
	os=mips-unknown-linux-gnu
fi

if [ "$DESTARCH" == "arm" ];then
	os=arm-unknown-linux-gnueabi
fi

if [ ! -f .configured ]; then
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	LD=$DESTARCH-linux-ld \
	STRIP=$DESTARCH-linux-strip \
	AR=$DESTARCH-linux-ar \
	RANLIB=$DESTARCH-linux-ranlib \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --prefix=$PREFIX --host=$os \
	--enable-static \
	--disable-rpath \
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

############# ###############################################################
# LIBGCRYPT # ###############################################################
############# ###############################################################
Status "compiling libgcrypt"

LIBGCRYPT_VERSION=1.10.1

cd $SRC/libgcrypt

if [ ! -f .extracted ]; then
	rm -rf libgcrypt libgcrypt-${LIBGCRYPT_VERSION}
	tar xvjf libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2
	mv libgcrypt-${LIBGCRYPT_VERSION} libgcrypt
	touch .extracted
fi

cd libgcrypt

if [ ! -f .configured ]; then
	PKG_CONFIG_PATH="$DEST/lib/pkgconfig" \
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	LD=$DESTARCH-linux-ld \
	STRIP=$DESTARCH-linux-strip \
	AR=$DESTARCH-linux-ar \
	RANLIB=$DESTARCH-linux-ranlib \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --prefix=$PREFIX --host=$os \
	--with-libgpg-error-prefix=$DEST \
	--enable-static \
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

############# ###############################################################
# LIBASSUAN # ###############################################################
############# ###############################################################
Status "compiling libassuan"

LIBASSUAN_VERSION=2.5.5

cd $SRC/libassuan

if [ ! -f .extracted ]; then
	rm -rf libassuan libassuan-${LIBASSUAN_VERSION}
	tar xvjf libassuan-${LIBASSUAN_VERSION}.tar.bz2
	mv libassuan-${LIBASSUAN_VERSION} libassuan
	touch .extracted
fi

cd libassuan

if [ ! -f .configured ]; then
	PKG_CONFIG_PATH="$DEST/lib/pkgconfig" \
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	LD=$DESTARCH-linux-ld \
	STRIP=$DESTARCH-linux-strip \
	AR=$DESTARCH-linux-ar \
	RANLIB=$DESTARCH-linux-ranlib \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --prefix=$PREFIX --host=$os \
	--with-libgpg-error-prefix=$DEST \
	--enable-static \
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

########### #################################################################
# LIBKSBA # #################################################################
########### #################################################################
Status "compiling libksba"

LIBKSBA_VERSION=1.6.0

cd $SRC/libksba

if [ ! -f .extracted ]; then
	rm -rf libksba libksba-${LIBKSBA_VERSION}
	tar xvjf libksba-${LIBKSBA_VERSION}.tar.bz2
	mv libksba-${LIBKSBA_VERSION} libksba
	touch .extracted
fi

cd libksba

if [ ! -f .configured ]; then
	PKG_CONFIG_PATH="$DEST/lib/pkgconfig" \
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	LD=$DESTARCH-linux-ld \
	STRIP=$DESTARCH-linux-strip \
	AR=$DESTARCH-linux-ar \
	RANLIB=$DESTARCH-linux-ranlib \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --prefix=$PREFIX --host=$os \
	--with-libgpg-error-prefix=$DEST \
	--enable-static \
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

######## ####################################################################
# NPTH # ####################################################################
######## ####################################################################
Status "compiling npth"

NPTH_VERSION=1.6

cd $SRC/npth

if [ ! -f .extracted ]; then
	rm -rf npth npth-${NPTH_VERSION}
	tar xvjf npth-${NPTH_VERSION}.tar.bz2
	mv npth-${NPTH_VERSION} npth
	touch .extracted
fi

cd npth

if [ ! -f .configured ]; then
	PKG_CONFIG_PATH="$DEST/lib/pkgconfig" \
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	LD=$DESTARCH-linux-ld \
	STRIP=$DESTARCH-linux-strip \
	AR=$DESTARCH-linux-ar \
	RANLIB=$DESTARCH-linux-ranlib \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --prefix=$PREFIX --host=$os \
	--enable-static
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
# GNUPG # ###################################################################
######### ###################################################################
Status "compiling gnupg"

GNUPG_VERSION=2.3.6

cd $SRC/gnupg

if [ ! -f .extracted ]; then
	rm -rf gnupg gnupg-${GNUPG_VERSION}
	tar xvjf gnupg-${GNUPG_VERSION}.tar.bz2
	mv gnupg-${GNUPG_VERSION} gnupg
	touch .extracted
fi

cd gnupg

if [ ! -f .configured ]; then
	PKG_CONFIG_PATH="$DEST/lib/pkgconfig" \
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	LD=$DESTARCH-linux-ld \
	STRIP=$DESTARCH-linux-strip \
	AR=$DESTARCH-linux-ar \
	RANLIB=$DESTARCH-linux-ranlib \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --prefix=$PREFIX --host=$os \
	--disable-rpath \
	--with-libgpg-error-prefix=$DEST \
	--with-gpg-error-prefix=$DEST \
	--with-libgcrypt-prefix=$DEST \
	--with-libassuan-prefix=$DEST \
	--with-ksba-prefix=$DEST \
	--with-npth-prefix=$DEST \
	--disable-ldap
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
# IKSEMEL # #################################################################
########### #################################################################
Status "compiling iksemel"

IKSEMEL_VERSION=1.5.1.3

export PKG_CONFIG_PATH=$DEST/lib/pkgconfig

cd $SRC/iksemel

if [ ! -f .extracted ]; then
	rm -rf iksemel iksemel-${IKSEMEL_VERSION}
	tar zxvf iksemel-${IKSEMEL_VERSION}.tar.gz
	mv iksemel-${IKSEMEL_VERSION} iksemel
	touch .extracted
fi

cd iksemel

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-gnutls \
	--disable-python \
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

unset PKG_CONFIG_PATH

######## ####################################################################
# SRTP # ####################################################################
######## ####################################################################
Status "compiling srtp"

SRTP_VERSION=2.4.2

cd $SRC/srtp

if [ ! -f .extracted ]; then
	rm -rf libsrtp libsrtp-${SRTP_VERSION}
	tar zxvf libsrtp-${SRTP_VERSION}.tar.gz
	mv libsrtp-${SRTP_VERSION} libsrtp
	touch .extracted
fi

cd libsrtp

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

############ ################################################################
# unixODBC # ################################################################
############ ################################################################
Status "compiling unixodbc"

UNIXODBC_VERSION=2.3.11

cd $SRC/odbc

if [ ! -f .extracted ]; then
	rm -rf unixODBC unixODBC-${UNIXODBC_VERSION}
	tar zxvf unixODBC-${UNIXODBC_VERSION}.tar.gz
	mv unixODBC-${UNIXODBC_VERSION} unixODBC
	touch .extracted
fi

cd unixODBC

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
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

########### #################################################################
# JANSSON # #################################################################
########### #################################################################
Status "compiling jannson"

JANSSON_VERSION=2.14

cd $SRC/jansson

if [ ! -f .extracted ]; then
	rm -rf jansson jansson-${JANSSON_VERSION}
	tar xvjf jansson-${JANSSON_VERSION}.tar.bz2
	mv jansson-${JANSSON_VERSION} jansson
	touch .extracted
fi

cd jansson

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

############ ################################################################
# ASTERISK # ################################################################
############ ################################################################
Status "compiling asterisk"

ASTERISK_VERSION=17.9.4

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/asterisk

if [ ! -f .extracted ]; then
	rm -rf asterisk asterisk-${ASTERISK_VERSION}
	tar zxvf asterisk-${ASTERISK_VERSION}.tar.gz
	mv asterisk-${ASTERISK_VERSION} asterisk
	touch .extracted
fi

cd asterisk

if [ ! -f .patched ]; then
	patch < $PATCHES/asterisk/010-asterisk-configure-undef-res-ninit.patch
	sed -i 's,\/etc\/localtime,'"$PREFIX"'\/etc\/localtime,g' main/stdtime/localtime.c
	touch .patched
fi

if [ "$DESTARCH" == "mipsel" ];then
	os=mipsel-tomatoware-linux-uclibc
fi

if [ "$DESTARCH" == "arm" ];then
	os=arm-tomatoware-linux-uclibcgnueabi
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS $CFLAGS" \
	CFLAGS="$CPPFLAGS $CFLAGS" \
	CXXFLAGS="$CPPFLAGS $CFLAGS" \
	./configure --prefix=$PREFIX --host=$os \
	--disable-rpath \
	--without-sdl \
	--without-lua \
	--disable-xmldoc \
	--with-externals-cache=$SRC/pjsip \
	--with-pjproject-bundled \
	--with-libedit=$DEST \
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
	--with-crypto=$DEST \
	--with-z=$DEST

	$MAKE1 menuselect.makeopts CC=cc CXX=g++ || true
	$MAKE1 menuselect.makeopts CC=cc CXX=g++
	./menuselect/menuselect --enable cdr_mysql menuselect.makeopts

	touch .configured
fi

if [ ! -f .built ]; then
	ASTLDFLAGS=$LDFLAGS \
	ASTCFLAGS="$CPPFLAGS $CFLAGS" \
	$MAKE \
	PJPROJECT_CONFIGURE_OPTS="--host=$os --with-ssl=$DEST"
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch .installed
fi

if [ ! -f .installed_example ]; then
	$MAKE1 install samples DESTDIR=$BASE
	mkdir -p $DEST/etc/config
	cp ../asterisk.wanup $DEST/etc/config
	sed -i 's,\/opt,'"$PREFIX"',g' $DEST/etc/config/asterisk.wanup
	touch .installed_example
fi

unset PKG_CONFIG_LIBDIR

######################## ####################################################
# ASTERISK CHAN_DONGLE # ####################################################
######################## ####################################################

#cd $SRC/asterisk

#if [ ! -f .extracted_chan_dongle ]; then
#	rm -rf asterisk-chan-dongle
#	tar zxvf asterisk-chan-dongle.tgz
#	touch .extracted_chan_dongle
#fi

#cd asterisk-chan-dongle

#if [ ! -f .pre-configured ]; then
#	patch < $PATCHES/asterisk/asterisk-chan-dongle.patch
#	./bootstrap
#	touch .pre-configured
#fi

#if [ ! -f .configured ]; then
#	DEST=$DEST \
#	LDFLAGS=$LDFLAGS \
#	CPPFLAGS=$CPPFLAGS \
#	CFLAGS=$CFLAGS \
#	CXXFLAGS=$CXXFLAGS \
#	$CONFIGURE \
#	--with-asterisk=$DEST/include \
#	--with-astversion=${ASTERISK_VERSION}
#	touch .configured
#fi

#if [ ! -f .built ]; then
#	$MAKE
#	touch .built
#fi

#if [ ! -f .installed ]; then
#	$MAKE1 install
#	touch .installed
#fi

###################### ######################################################
# TIME ZONE DATABASE # ######################################################
###################### ######################################################
Status "compiling time zone database"

TZ_VERSION=2022a

cd $SRC/tz

if [ ! -f .extracted ]; then
	rm -rf tz tz-native
	mkdir tz
	tar zxvf tzcode${TZ_VERSION}.tar.gz -C ./tz
	tar zxvf tzdata${TZ_VERSION}.tar.gz -C ./tz
	cp -r tz tz-native
	touch .extracted
fi

cd tz-native

if [ ! -f .installed ]; then
	$MAKE1 \
	TOPDIR=$PREFIX \
	DESTDIR=$BASE
	touch .installed
fi

cd ../tz

if [ ! -f .installed ]; then
	$MAKE1 install \
	cc=$DESTARCH-linux-gcc \
	LFLAGS="$LDFLAGS" \
	CFLAGS="$CFLAGS" \
	TOPDIR=$PREFIX \
	USRDIR="" \
	DESTDIR=$BASE \
	zic=../tz-native/zic
	touch .installed
fi

########## ##################################################################
# XXHASH # ##################################################################
########## ##################################################################
Status "compiling xxhash"

XXHASH_VERSION=0.8.1

cd $SRC/xxhash

if [ ! -f .extracted ]; then
	rm -rf xxHash xxHash-${XXHASH_VERSION}
	tar xvJf xxHash-${XXHASH_VERSION}.tar.xz
	mv xxHash-${XXHASH_VERSION} xxHash
	touch .extracted
fi

cd xxHash

if [ ! -f .built ]; then
	CC=$DESTARCH-linux-gcc \
	CFLAGS="-std=c99 $CFLAGS" \
	LDFLAGS=$LDFLAGS \
	prefix=$PREFIX \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	CC=$DESTARCH-linux-gcc \
	CFLAGS="-std=c99 $CFLAGS" \
	LDFLAGS=$LDFLAGS \
	prefix=$PREFIX \
	$MAKE1 install \
	DESTDIR=$BASE
	touch .installed
fi

####### #####################################################################
# APT # #####################################################################
####### #####################################################################
Status "compiling apt"

APT_VERSION=2.4.5

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/apt

if [ ! -f .extracted ]; then
	rm -rf apt apt-${APT_VERSION}
	tar xvJf apt-${APT_VERSION}.tar.xz
	mv apt-${APT_VERSION} apt
	cp $SRC/apt/triehash $BASE/native/bin
	touch .extracted
fi

cd apt

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/apt/apt-no-nquery.patch
	patch -p1 < $PATCHES/apt/apt-remove-dpkg-path.patch
	patch -p1 < $PATCHES/apt/apt-cstdarg.patch
	patch -p1 < $PATCHES/apt/apt-sandbox-as-nobody.patch
	touch .patched
fi


if [ ! -f .configured ]; then
	cmake \
	-Wno-dev \
	-DCMAKE_SYSTEM_NAME="Linux" \
	-DDPKG_DATADIR=$PREFIX/share/dpkg \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_INCLUDE_PATH=$DEST/include \
	-DCMAKE_LIBRARY_PATH=$DEST/lib \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DCMAKE_C_FLAGS="$CPPFLAGS $CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CPPFLAGS $CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	-DBERKELEY_INCLUDE_DIRS=$DEST/include \
	-DWITH_DOC=OFF \
	-DWITH_TESTS=OFF \
	.
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	echo "APT::Architecture \"$DESTARCH\";" > $DEST/etc/apt/apt.conf
	sed -i -e '1,1s,\#\!\/bin\/sh,\#\!'"$PREFIX"'\/bin\/bash,g' $DEST/bin/apt-key
	touch .installed
fi

if [ ! -f .repo ]; then
	mkdir -p $DEST/share/keyrings
	cat $SRC/apt/apt_pub.gpg | gpg --dearmor > $DEST/share/keyrings/tomatoware-archive-keyring.gpg
	cp $SRC/apt/tomatoware.list $DEST/etc/apt/sources.list.d
	touch .repo
fi

unset PKG_CONFIG_LIBDIR

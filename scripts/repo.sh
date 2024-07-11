#!/bin/bash

source ./scripts/environment.sh

######### ###################################################################
# LIBMD # ###################################################################
######### ###################################################################
Status "compiling libmd"

LIBMD_VERSION=1.1.0

cd $SRC/libmd

if [ ! -f .extracted ]; then
	rm -rf libmd libmd-${LIBMD_VERSION}
	tar xvJf libmd-${LIBMD_VERSION}.tar.xz
	mv libmd-${LIBMD_VERSION} libmd
	touch .extracted
fi

cd libmd

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
# DPKG # ####################################################################
######## ####################################################################
Status "compiling dpkg"

DPKG_VERSION=1.22.6

cd $SRC/dpkg

if [ ! -f .extracted ]; then
	rm -rf dpkg dpkg-${DPKG_VERSION}
	tar xvJf dpkg-${DPKG_VERSION}.tar.xz
	mv dpkg-${DPKG_VERSION} dpkg
	touch .extracted
fi

cd dpkg

if [ ! -f .patched ]; then
	patch -p1 < $PATCHES/dpkg/dpkg-silence-warnings.patch
	touch .patched
fi


if [ ! -f .configured ]; then
	PATH=$SRC/perl/native/bin:$PATH \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure \
	--prefix=$PREFIX \
	--host=$DESTARCH-linux \
	--disable-rpath \
	--with-sysroot=$PREFIX \
	--without-libselinux \
	PERL_LIBDIR=$PREFIX/lib/perl5/${PERL_VERSION}
	touch .configured
fi

if [ ! -f .built ]; then
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	$MAKE1 install DESTDIR=$BASE
	touch $DEST/var/lib/dpkg/status
	touch .installed
fi

if [ ! -f .edit_sed ]; then
	grep -Irl $SRC\/perl\/native $DEST | xargs sed -i -e '1,1s,'"$SRC"'/perl/native,'"$PREFIX"',g'
	touch .edit_sed
fi

if [ ! -f .ldconfig ]; then
	ln -sf true $DEST/bin/ldconfig
	touch .ldconfig
fi

########## ##################################################################
# NETTLE # ##################################################################
########## ##################################################################
Status "compiling nettle"

NETTLE_VERSION=3.10

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

GNUTLS_VERSION=3.8.6

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
	CFLAGS="$CFLAGS -Wno-missing-include-dirs" \
	CXXFLAGS="$CXXFLAGS -Wno-missing-include-dirs" \
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

LIBGPG_ERROR_VERSION=1.50

cd $SRC/libgpg-error

if [ ! -f .extracted ]; then
	rm -rf libgpg-error libgpg-error-${LIBGPG_ERROR_VERSION}
	tar xvjf libgpg-error-${LIBGPG_ERROR_VERSION}.tar.bz2
	mv libgpg-error-${LIBGPG_ERROR_VERSION} libgpg-error
	touch .extracted
fi

cd libgpg-error

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure \
	--prefix=$PREFIX \
	--host=$DESTARCH-linux \
	--enable-install-gpg-error-config \
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

LIBGCRYPT_VERSION=1.11.0

cd $SRC/libgcrypt

if [ ! -f .extracted ]; then
	rm -rf libgcrypt libgcrypt-${LIBGCRYPT_VERSION}
	tar xvjf libgcrypt-${LIBGCRYPT_VERSION}.tar.bz2
	mv libgcrypt-${LIBGCRYPT_VERSION} libgcrypt
	touch .extracted
fi

cd libgcrypt

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
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

LIBASSUAN_VERSION=3.0.1

cd $SRC/libassuan

if [ ! -f .extracted ]; then
	rm -rf libassuan libassuan-${LIBASSUAN_VERSION}
	tar xvjf libassuan-${LIBASSUAN_VERSION}.tar.bz2
	mv libassuan-${LIBASSUAN_VERSION} libassuan
	touch .extracted
fi

cd libassuan

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
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

LIBKSBA_VERSION=1.6.7

cd $SRC/libksba

if [ ! -f .extracted ]; then
	rm -rf libksba libksba-${LIBKSBA_VERSION}
	tar xvjf libksba-${LIBKSBA_VERSION}.tar.bz2
	mv libksba-${LIBKSBA_VERSION} libksba
	touch .extracted
fi

cd libksba

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
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

NPTH_VERSION=1.7

cd $SRC/npth

if [ ! -f .extracted ]; then
	rm -rf npth npth-${NPTH_VERSION}
	tar xvjf npth-${NPTH_VERSION}.tar.bz2
	mv npth-${NPTH_VERSION} npth
	touch .extracted
fi

cd npth

if [ ! -f .patched ]; then
	for file in $PATCHES/npth/*.patch
	do
		patch -p1 < "$file"
	done
	touch .patched
fi

if [ ! -f .configured ]; then
	autoreconf -fsi
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-install-npth-config \
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

GNUPG_VERSION=2.4.5

cd $SRC/gnupg

if [ ! -f .extracted ]; then
	rm -rf gnupg gnupg-${GNUPG_VERSION}
	tar xvjf gnupg-${GNUPG_VERSION}.tar.bz2
	mv gnupg-${GNUPG_VERSION} gnupg
	touch .extracted
fi

cd gnupg

if [ ! -f .patched ]; then
	sed -e '/ks_ldap_free_state/i #if USE_LDAP' \
	    -e '/ks_get_state =/a #endif' \
	    -i dirmngr/server.c
	touch .patched
fi

if [ ! -f .configured ]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
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

###################### ######################################################
# TIME ZONE DATABASE # ######################################################
###################### ######################################################
Status "compiling time zone database"

TZ_VERSION=2022f

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

if [[ "$DESTARCH" == "mipsel" || "$DESTARCH" == "arm" ]];then
	GETRANDOM="-DHAVE_GETRANDOM=0"
fi

if [ ! -f .installed ]; then
	$MAKE1 install \
	cc=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	LFLAGS="$LDFLAGS" \
	CFLAGS="$CFLAGS $GETRANDOM" \
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
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
	CFLAGS="-std=c99 $CFLAGS" \
	LDFLAGS=$LDFLAGS \
	prefix=$PREFIX \
	$MAKE
	touch .built
fi

if [ ! -f .installed ]; then
	CC=$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc \
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

APT_VERSION=2.5.4

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
	-DCMAKE_C_COMPILER=`which $DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI-g++` \
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

	if [ "$DESTARCH" == "arm" ] || [ "$DESTARCH" == "mipsel" ]; then
		echo "APT::Architecture \"$DESTARCH\";" > $DEST/etc/apt/apt.conf
	fi

	if [ "$DESTARCH" == "aarch64" ]; then
		echo "APT::Architecture \"arm64\";" > $DEST/etc/apt/apt.conf
	fi

	sed -i -e '1,1s,\#\!\/bin\/sh,\#\!'"$PREFIX"'\/bin\/bash,g' $DEST/bin/apt-key
	touch .installed
fi

if [ ! -f .repo ]; then
	mkdir -p $DEST/share/keyrings
	cat $SRC/apt/apt_pub.gpg | gpg --dearmor > $DEST/share/keyrings/tomatoware-archive-keyring.gpg
	cp $SRC/apt/tomatoware.list $DEST/etc/apt/sources.list.d

	if [ "$DESTARCH" == "arm" ];then
		sed -i 's,main,main '"$DESTARCHLIBC"',g' \
		$DEST/etc/apt/sources.list.d/tomatoware.list
	fi
	touch .repo
fi

unset PKG_CONFIG_LIBDIR

#!/bin/bash

set -e
set -x

export BASE=`pwd`
export SRC=$BASE/src
export PATCHES=$BASE/patches

if [ ! -d /opt/tomatoware ]
then
	sudo mkdir -p /opt/tomatoware
	sudo chmod -R 777 /opt/tomatoware
fi

if [ ! -d /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-} ]
then
	mkdir $BASE/toolchain
	tar zxvf $SRC/toolchain/buildroot-2017.02.tar.gz -C $BASE/toolchain
	cp $SRC/toolchain/defconfig.$DESTARCH $BASE/toolchain/buildroot-2017.02/defconfig
	cp -r $SRC/toolchain/patches $BASE/toolchain
	mv $BASE/toolchain/patches/linux-headers.$DESTARCH $BASE/toolchain/patches/linux-headers
	echo "UCLIBC_HAS_BACKTRACE=y" >> $BASE/toolchain/buildroot-2017.02/package/uclibc/uClibc-ng.config
	echo "# UCLIBC_USE_MIPS_PREFETCH is not set" >> $BASE/toolchain/buildroot-2017.02/package/uclibc/uClibc-ng.config
#	echo "sha256 1c7e5cf82b034929edb9c7e584abfaf1c62fb087b64b73fcfc6315570690119a uClibc-ng-1.0.22.tar.xz" >> $BASE/toolchain/buildroot-2017.02/package/uclibc/uclibc.hash
#	sed -i 's,1.0.20,1.0.22,g' $BASE/toolchain/buildroot-2017.02/package/uclibc/uclibc.mk
	sed -i 's,f2004c85db8e07e9f1c2e8b7c513fa7c237bc9f9685d8e1bfc89535b8a85449b,1c7e5cf82b034929edb9c7e584abfaf1c62fb087b64b73fcfc6315570690119a,g' $BASE/toolchain/buildroot-2017.02/package/uclibc/uclibc.hash

	sed -i 's,\/opt,'"$PREFIX"',g' \
	$BASE/toolchain/patches/uclibc/001-uclibc-ldso-search-path.patch \
	$BASE/toolchain/patches/uclibc/002-uclibc-ldconfig-opt.patch \
	$BASE/toolchain/patches/uclibc/003-uclibc-dl-defs.patch \
	$BASE/toolchain/patches/uclibc/004-uclibc-ldd-opt.patch

	cd $BASE/toolchain/buildroot-2017.02
	make defconfig BR2_DEFCONFIG=defconfig
	make

fi

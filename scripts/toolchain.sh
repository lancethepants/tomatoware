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
	tar zxvf $SRC/toolchain/buildroot-2016.02.tar.gz -C $BASE/toolchain
	cp $SRC/toolchain/config.$DESTARCH $BASE/toolchain/buildroot-2016.02/.config
	cp -r $SRC/toolchain/patches $BASE/toolchain
	mv $BASE/toolchain/patches/linux-headers.$DESTARCH $BASE/toolchain/patches/linux-headers
	echo "UCLIBC_HAS_BACKTRACE=y" >> $BASE/toolchain/buildroot-2016.02/package/uclibc/uClibc-ng.config
	echo "DO_XSI_MATH=y" >> $BASE/toolchain/buildroot-2016.02/package/uclibc/uClibc-ng.config
	echo "sha256 3c63d9f8c8b98b65fa5c4040d1c8ab1b36e99a16e1093810cedad51ac15c9a9e uClibc-ng-1.0.14.tar.xz" >> $BASE/toolchain/buildroot-2016.02/package/uclibc/uclibc.hash
	sed -i 's,1.0.13,1.0.14,g' $BASE/toolchain/buildroot-2016.02/package/uclibc/uclibc.mk

	sed -i 's,\/opt,'"$PREFIX"',g' \
	$BASE/toolchain/patches/uclibc/001-uclibc-ldso-search-path.patch \
	$BASE/toolchain/patches/uclibc/002-uclibc-ldconfig-opt.patch \
	$BASE/toolchain/patches/uclibc/003-uclibc-dl-defs.patch \
	$BASE/toolchain/patches/uclibc/004-uclibc-ldd-opt.patch

	cd $BASE/toolchain/buildroot-2016.02
	make

fi

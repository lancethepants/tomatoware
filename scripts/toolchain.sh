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
	tar zxvf $SRC/toolchain/buildroot-2016.05.tar.gz -C $BASE/toolchain
	cp $SRC/toolchain/config.$DESTARCH $BASE/toolchain/buildroot-2016.05/.config
	cp -r $SRC/toolchain/patches $BASE/toolchain
	mv $BASE/toolchain/patches/linux-headers.$DESTARCH $BASE/toolchain/patches/linux-headers
	echo "UCLIBC_HAS_BACKTRACE=y" >> $BASE/toolchain/buildroot-2016.05/package/uclibc/uClibc-ng.config
	echo "# UCLIBC_USE_MIPS_PREFETCH is not set" >> $BASE/toolchain/buildroot-2016.05/package/uclibc/uClibc-ng.config
	echo "sha256 a2e7207634c19997e8b9f3e712182d80d42aaa85ce3462eff1a9bce812aaf354 uClibc-ng-1.0.17.tar.xz" >> $BASE/toolchain/buildroot-2016.05/package/uclibc/uclibc.hash
	sed -i 's,1.0.14,1.0.17,g' $BASE/toolchain/buildroot-2016.05/package/uclibc/uclibc.mk

	sed -i 's,\/opt,'"$PREFIX"',g' \
	$BASE/toolchain/patches/uclibc/001-uclibc-ldso-search-path.patch \
	$BASE/toolchain/patches/uclibc/002-uclibc-ldconfig-opt.patch \
	$BASE/toolchain/patches/uclibc/003-uclibc-dl-defs.patch \
	$BASE/toolchain/patches/uclibc/004-uclibc-ldd-opt.patch

	cd $BASE/toolchain/buildroot-2016.05
	make

fi

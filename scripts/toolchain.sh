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
	tar zxvf $SRC/toolchain/buildroot-2016.11.tar.gz -C $BASE/toolchain
	cp $SRC/toolchain/defconfig.$DESTARCH $BASE/toolchain/buildroot-2016.11/defconfig
	cp -r $SRC/toolchain/patches $BASE/toolchain
	mv $BASE/toolchain/patches/linux-headers.$DESTARCH $BASE/toolchain/patches/linux-headers
	echo "UCLIBC_HAS_BACKTRACE=y" >> $BASE/toolchain/buildroot-2016.11/package/uclibc/uClibc-ng.config
	echo "# UCLIBC_USE_MIPS_PREFETCH is not set" >> $BASE/toolchain/buildroot-2016.11/package/uclibc/uClibc-ng.config
#	echo "sha256 1632cac9ec87875e888dea75a38354c45e419c17559099b6e3880641746a5c0f uClibc-ng-1.0.19.tar.xz" >> $BASE/toolchain/buildroot-2016.11/package/uclibc/uclibc.hash
#	sed -i 's,1.0.14,1.0.19,g' $BASE/toolchain/buildroot-2016.11/package/uclibc/uclibc.mk
	sed -i 's,1c817672a65cf9132c98f84e1b8445650de1c18eca258f49c0050b420a25e946,80a5ac500dd859da9e868fdf9ef540aab9e375af42401a0fb0e39b03c79ae8c2,g' $BASE/toolchain/buildroot-2016.11/package/uclibc/uclibc.hash

	sed -i 's,\/opt,'"$PREFIX"',g' \
	$BASE/toolchain/patches/uclibc/001-uclibc-ldso-search-path.patch \
	$BASE/toolchain/patches/uclibc/002-uclibc-ldconfig-opt.patch \
	$BASE/toolchain/patches/uclibc/003-uclibc-dl-defs.patch \
	$BASE/toolchain/patches/uclibc/004-uclibc-ldd-opt.patch

	cd $BASE/toolchain/buildroot-2016.11
	make defconfig BR2_DEFCONFIG=defconfig
	make

fi

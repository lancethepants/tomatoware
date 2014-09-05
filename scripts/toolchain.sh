#!/bin/bash

set -e
set -x

BASE=`pwd`
export PATCHES=$BASE/patches

if [ ! -d /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-} ]
then
	mkdir $BASE/toolchain && cd $BASE/toolchain
	git clone https://github.com/Entware/entware.git
	cd ./entware/toolchain

	sed -i 's,\/opt,'"$PREFIX"',g' \
	patches-uclibc/001-uclibc-ldso-search-path.patch \
	patches-uclibc/002-uclibc-ldconfig-opt.patch \
	patches-uclibc/003-uclibc-dl-defs.patch \
	patches-uclibc/004-uclibc-ldd-opt.patch

	sed -i 's,#FORCE_COMPILE=y,FORCE_COMPILE=y,g' ../config.mk
	sed -i 's,entware,tomatoware,g' Makefile
	sed -i 's,toolchain-$(TARGET),$(DESTARCH)-$(FLOAT)$(subst \/\,\-\,$(PREFIX)),g' Makefile

	if [ "$DESTARCH" = "mipsel" ] && [ "$FLOAT" = "soft" ];
	then
		sed -i 's,export TARGET=entware,#export TARGET=entware,g' ../config.mk
		sed -i 's,#export TARGET=mipselsf,export TARGET=mipselsf,g' ../config.mk
		sed -i "s,/opt/entware/toolchain-mipselsf,/opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-},g" patches-mipselsf/define-toolchain-path.patch
	fi

	if [ "$DESTARCH" = "mipsel" ] && [ "$FLOAT" = "hard" ];
	then
		sed -i "s,/opt/entware/toolchain-entware,/opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-},g" patches-entware/define-toolchain-path.patch
	fi

	if [ "$DESTARCH" = "arm" ];
	then
		tar xvJf $PATCHES/toolchain/linux-2.6.36.4.tar.xz -C $BASE/toolchain
		patch -p1 -d $BASE/toolchain/linux-2.6.36.4 < $PATCHES/toolchain/kernel.patch
		cp -r $PATCHES/toolchain/patches-arm .
		sed -i 's,TARGET=entware,TARGET=arm,g' ../config.mk
		sed -i "s,/opt/entware/toolchain-arm,/opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-},g" patches-arm/define-toolchain-path.patch
		sed -i "s,linux-2.6.22.19,linux-2.6.36.4,g" Makefile
	fi

	cd ..

	if [ "$DESTARCH" = "mipsel" ];
	then
		make -C "kernel-2.6.22.19"
	fi

	make -C "toolchain"
fi

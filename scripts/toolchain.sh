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

#	patch -p1 Makefile < $PATCHES/toolchain/mipsel-hardfloat.patch
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

	cd ..
	make -C "kernel-2.6.22.19"
	make -C "toolchain"
fi

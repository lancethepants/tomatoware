#!/bin/bash

set -e
set -x

export BASE=`pwd`
export SRC=$BASE/src
export PATCHES=$BASE/patches

if [ "$DESTARCH" = "mipsel" ] && [ ! -d /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-} ]
then
	if [ ! -d /opt/tomatoware ]
	then
		sudo mkdir -p /opt/tomatoware
		sudo chmod -R 777 /opt/tomatoware
	fi

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

	if [ "$FLOAT" = "soft" ];
	then
		sed -i 's,export TARGET=entware,#export TARGET=entware,g' ../config.mk
		sed -i 's,#export TARGET=mipselsf,export TARGET=mipselsf,g' ../config.mk
		sed -i "s,/opt/entware/toolchain-mipselsf,/opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-},g" patches-mipselsf/define-toolchain-path.patch
	fi

	if [ "$FLOAT" = "hard" ];
	then
		sed -i "s,/opt/entware/toolchain-entware,/opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-},g" patches-entware/define-toolchain-path.patch
	fi

	cd ..

	make -C "kernel-2.6.22.19"
	make -C "toolchain"
fi

if [ "$DESTARCH" = "arm" ] && [ ! -d /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-} ]
then
	if [ ! -d /opt/tomatoware ]
	then
		sudo mkdir -p /opt/tomatoware
		sudo chmod -R 777 /opt/tomatoware
	fi

	mkdir $BASE/toolchain && cd $BASE/toolchain
	tar zxvf $SRC/arm-toolchain/buildroot-2014.11.tar.gz -C $BASE/toolchain
	cp $SRC/arm-toolchain/.config $BASE/toolchain/buildroot-2014.11
	cp -r $SRC/arm-toolchain/patches $BASE/toolchain

	sed -i 's,\/opt,'"$PREFIX"',g' \
	$BASE/toolchain/patches/uclibc/001-uclibc-ldso-search-path.patch \
	$BASE/toolchain/patches/uclibc/002-uclibc-ldconfig-opt.patch \
	$BASE/toolchain/patches/uclibc/003-uclibc-dl-defs.patch \
	$BASE/toolchain/patches/uclibc/004-uclibc-ldd-opt.patch

	cd $BASE/toolchain/buildroot-2014.11
	make

fi

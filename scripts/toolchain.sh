#!/bin/bash

set -e
set -x

BASE=`pwd`
export PATCHES=$BASE/patches

if [ ! -d /opt/entware-toolchain-$DESTARCH${PREFIX////-} ]
then

	mkdir $BASE/toolchain
	cd $BASE/toolchain
	git clone https://github.com/Entware/entware.git
	cd ./entware/toolchain/mipsel-hardfloat
	patch -p1 Makefile < $PATCHES/toolchain/mipsel-hardfloat.patch
	sed -i 's,\/opt\/entware-toolchain,\/opt\/entware-toolchain-'"$DESTARCH${PREFIX////-}"',g' Makefile define-toolchain-path.patch
	sed -i 's,\/opt,'"$PREFIX"',g' \
	001-uclibc-ldso-search-path.patch \
	002-uclibc-ldconfig-opt.patch \
	003-uclibc-dl-defs.patch \
	004-uclibc-ldd-opt.patch
	
	if [ "$DESTARCH" == "arm" ];then
		sed -i 's,.toolchain .kernel,.toolchain-2.6.36 .kernel-2.6.36,g' Makefile
	fi	

	make


fi

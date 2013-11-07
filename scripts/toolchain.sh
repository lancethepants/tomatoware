#!/bin/bash

set -e
set -x

BASE=`pwd`

if [ ! -d /opt/entware-toolchain ]
then

	mkdir $BASE/toolchain
	cd $BASE/toolchain
	svn co http://wl500g-repo.googlecode.com/svn/trunk/ ./rtn
	cd ./rtn/toolchain/mipsel-hardfloat
	sed -i 's,\/opt,'"$PREFIX"',g' \
	001-uclibc-ldso-search-path.patch \
	002-uclibc-ldconfig-opt.patch \
	003-uclibc-dl-defs.patch \
	004-uclibc-ldd-opt.patch
	make


fi

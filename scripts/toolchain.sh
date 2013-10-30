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
	make


fi

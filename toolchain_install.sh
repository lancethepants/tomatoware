#!/bin/bash

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
PATCHES=$BASE/patches
RPATH=/opt/lib
DEST=$BASE/opt
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0 -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
CPPFLAGS="-I$DEST/include -I$DEST/include/ncurses"
CFLAGS="-mtune=mips32 -mips32"
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make -j2"

if [ ! -d /opt/entware-toolchain ]
then
cd /opt
sudo $WGET http://wl500g-repo.googlecode.com/files/entware-toolchain-r4667-amd64.tgz
sudo tar zxvf entware-toolchain-r4667-amd64.tgz -C /
sudo rm -rf opt/ entware-toolchain-r4667-amd64.tgz
fi

cd $BASE

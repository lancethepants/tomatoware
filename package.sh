#!/bin/sh

BASE=`pwd`
DEST_LIB=$BASE/tomato/lib
SOURCE_LIB=$BASE/toolchain/lib

cp -f $SOURCE_LIB/ld-uClibc-0.9.32.so $DEST_LIB
ln -sf ld-uClibc-0.9.32.so $DEST_LIB/ld-uClibc.so.0

cp -f $SOURCE_LIB/libuClibc-0.9.32.so $DEST_LIB
ln -sf libuClibc-0.9.32.so $DEST_LIB/libc.so.0

cp -f $SOURCE_LIB/libcrypt-0.9.32.so $DEST_LIB
ln -sf libcrypt-0.9.32.so $DEST_LIB/libcrypt.so.0

cp -f $SOURCE_LIB/libdl-0.9.32.so $DEST_LIB
ln -sf libdl-0.9.32.so $DEST_LIB/libdl.so.0

cp -f $SOURCE_LIB/libm-0.9.32.so $DEST_LIB
ln -sf libm-0.9.32.so $DEST_LIB/libm.so.0

cp -f $SOURCE_LIB/libnsl-0.9.32.so $DEST_LIB
ln -sf libnsl-0.9.32.so $DEST_LIB/libnsl.so.0

cp -f $SOURCE_LIB/libpthread-0.9.32.so $DEST_LIB
ln -sf libpthread-0.9.32.so $DEST_LIB/libpthread.so.0

cp -f $SOURCE_LIB/libresolv-0.9.32.so $DEST_LIB
ln -sf libresolv-0.9.32.so $DEST_LIB/libresolv.so.0

cp -f $SOURCE_LIB/librt-0.9.32.so $DEST_LIB
ln -sf librt-0.9.32.so $DEST_LIB/librt.so.0

cp -f $SOURCE_LIB/libstdc++.so.6.0.16 $DEST_LIB
ln -sf libstdc++.so.6.0.16 $DEST_LIB/libstdc++.so
ln -sf libstdc++.so.6.0.16 $DEST_LIB/libstdc++.so.6

cp -f $SOURCE_LIB/libssp.so.0.0.0 $DEST_LIB
ln -sf libssp.so.0.0.0 $DEST_LIB/libssp.so
ln -sf libssp.so.0.0.0 $DEST_LIB/libssp.so.0

cd $BASE/tomato

tar zvcf ../opt.tgz bin/ docs/ include/ lib/ man/ python_modules/ sbin/ share/ ssl/

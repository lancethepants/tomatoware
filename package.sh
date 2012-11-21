#!/bin/sh

BASE=`pwd`
DEST_LIB=$BASE/opt/lib
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

cp -f $SOURCE_LIB/libutil-0.9.32.so $DEST_LIB
ln -sf libutil-0.9.32.so $DEST_LIB/libutil.so
ln -sf libutil-0.9.32.so $DEST_LIB/libutil.so.0

cp -f $SOURCE_LIB/libgcc_s.so.1 $DEST_LIB
ln -sf libgcc_s.so.1 $DEST_LIB/libgcc_s.so

cd $BASE/opt/python_modules

if [ ! -d setuptools ]
then

mkdir setuptools && cd setuptools
wget http://pypi.python.org/packages/source/s/setuptools/setuptools-0.6c11.tar.gz

fi

cd $BASE/opt/python_modules

if [ ! -d markdown ]
then

mkdir markdown && cd markdown
wget http://pypi.python.org/packages/source/M/Markdown/Markdown-2.2.1.tar.gz

fi

cd $BASE/opt/python_modules

echo "#!/bin/sh" > install_modules.sh

echo "cd /opt/python_modules/setuptools" >> install_modules.sh
echo "rm -rf setuptools-0.6c11" >> install_modules.sh
echo "tar zxvf setuptools-0.6c11.tar.gz" >> install_modules.sh
echo "cd setuptools-0.6c11/" >> install_modules.sh
echo "./setup.py build" >> install_modules.sh
echo "./setup.py install" >> install_modules.sh

echo "cd /opt/python_modules/markdown" >> install_modules.sh
echo "rm -rf Markdown-2.2.1" >> install_modules.sh
echo "tar zxvf Markdown-2.2.1.tar.gz" >> install_modules.sh
echo "cd Markdown-2.2.1/" >> install_modules.sh
echo "./setup.py build" >> install_modules.sh
echo "./setup.py install" >> install_modules.sh

echo "cd /opt/python_modules" >> install_modules.sh
echo "easy_install -Z Cheetah-2.4.4-py2.7.egg" >> install_modules.sh
echo "easy_install -Z pyOpenSSL-0.13-py2.7.egg " >> install_modules.sh
echo "easy_install -Z yenc-0.4.0-py2.7.egg" >> install_modules.sh

chmod +x install_modules.sh

cd $BASE/opt

tar zvcf $BASE/opt.tgz bin/ docs/ etc/ include/ lib/ libexec/ man/ python_modules/ sbin/ share/ ssl/ var/

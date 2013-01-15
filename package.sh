#!/bin/bash

BASE=`pwd`

DEST=$BASE/opt
TOOLCHAIN=/opt/entware-toolchain/
SOURCE_INCLUDE=$TOOLCHIAN/include
SOURCE_LIB=$TOOLCHAIN/lib
DEST_LIB=$DEST/lib

cp -rf $SOURCE_INCLUDE $DEST

shopt -s extglob
cp -r $SOURCE_LIB/!(gcc) $DEST_LIB

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

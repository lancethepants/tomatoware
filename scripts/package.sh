#!/bin/bash

set -e
set -x

BASE=`pwd`
DEST=$BASE$PREFIX
SRC=$BASE/src

find $DEST/lib -iname \*.la -exec sed -i 's,'"$BASE"',,g' {} \;

if [ -f $DEST/bin/libgnutls-config ]; then
	sed -i 's,\/bin\/bash,'"$PREFIX"'\/bin\/bash,g' $DEST/bin/libgnutls-config
fi

cp -rf /opt/entware-toolchain/include $DEST

cp -rf /opt/entware-toolchain/lib $DEST

cp $SRC/.autorun $DEST
sed -i 's,\/opt,'"$PREFIX"',g' $DEST/.autorun

cd $BASE$PREFIX/python_modules

if [ ! -d setuptools ]
then
	mkdir setuptools && cd setuptools
	cp $BASE/src/setuptools/setuptools.tar.gz .
fi

cd $BASE$PREFIX/python_modules

if [ ! -d markdown ]
then
	mkdir markdown && cd markdown
	cp $BASE/src/markdown/Markdown-2.3.1.tar.gz .
fi

cd $BASE$PREFIX/python_modules

echo "#!/bin/sh" > install_modules.sh

echo "cd $PREFIX/python_modules/setuptools" >> install_modules.sh
echo "rm -rf setuptools" >> install_modules.sh
echo "tar zxvf setuptools.tar.gz" >> install_modules.sh
echo "cd setuptools/" >> install_modules.sh
echo "python ./setup.py build" >> install_modules.sh
echo "python ./setup.py install" >> install_modules.sh

echo "cd $PREFIX/python_modules/markdown" >> install_modules.sh
echo "rm -rf Markdown-2.3.1" >> install_modules.sh
echo "tar zxvf Markdown-2.3.1.tar.gz" >> install_modules.sh
echo "cd Markdown-2.3.1/" >> install_modules.sh
echo "python ./setup.py build" >> install_modules.sh
echo "python ./setup.py install" >> install_modules.sh

echo "cd $PREFIX/python_modules" >> install_modules.sh
echo "easy_install -Z Cheetah-2.4.4-py2.7.egg" >> install_modules.sh
echo "easy_install -Z pyOpenSSL-0.13.1-py2.7.egg " >> install_modules.sh
echo "easy_install -Z yenc-0.4.0-py2.7.egg" >> install_modules.sh

chmod +x install_modules.sh

cd $DEST/etc

echo "#!/bin/sh" > profile
echo "" >> profile
echo "# Please note it's not a system-wide settings, it's only for a current" >> profile
echo "# terminal session. Point your f\w (if necessery) to execute $PREFIX/etc/profile" >> profile
echo "# at console logon." >> profile
echo "" >> profile
echo "export PATH='$PREFIX/usr/sbin:$PREFIX/sbin:$PREFIX/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'" >> profile
echo "export TERM=xterm" >> profile
echo "export TMP=$PREFIX/tmp" >> profile
echo "export TEMP=$PREIFX/tmp" >> profile
echo "export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig" >> profile
echo "export M4=$PREFIX/bin/m4" >> profile
echo "" >> profile
echo "# You may define localization" >> profile
echo "#export LANG='ru_RU.UTF-8'" >> profile
echo "#export LC_ALL='ru_RU.UTF-8'" >> profile
echo "" >> profile
echo "alias ls='ls --color'" >> profile
echo "alias o='cd $PREFIX'" >> profile
echo "alias uptime='/usr/bin/uptime'" >> profile

chmod +x profile

cd $BASE$PREFIX

tar zvcf $BASE$PREFIX.tgz bin/ docs/ etc/ include/ lib/ libexec/ man/ python_modules/ sbin/ share/ ssl/ var/ .autorun .vimrc

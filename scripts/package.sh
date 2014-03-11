#!/bin/bash

set -e
set -x

BASE=`pwd`
DEST=$BASE$PREFIX
SRC=$BASE/src

#Remove build path directory $BASE from all libtool .la files.
#This makes sure the libtool files show the correct paths to libraries for the deployment system.
find $DEST/lib -iname \*.la -exec sed -i 's,'"$BASE"',,g' {} \;

#Make sure all perl scripts have the correct interpreter path.
grep -Irl "\#\!\/usr\/bin\/perl" $DEST | xargs sed -i -e '1,1s,\#\!\/usr\/bin\/perl,\#\!'"$PREFIX"'\/bin\/perl,g'
grep -Irl "\#\! \/usr\/bin\/perl" $DEST | xargs sed -i -e '1,1s,\#\! \/usr\/bin\/perl,\#\! '"$PREFIX"'\/bin\/perl,g'

#Set correct path in gnutls script.
if [ -f $DEST/bin/libgnutls-config ]; then
	sed -i 's,\/bin\/bash,'"$PREFIX"'\/bin\/bash,g' $DEST/bin/libgnutls-config
fi

#Copy lib and include files from toolchain for use in the deployment system.
cp -rf /opt/entware-toolchain/include $DEST
cp -rf /opt/entware-toolchain/lib $DEST

#Copy and set correct interpreter path for the .autorun file
cp $SRC/.autorun $DEST
sed -i 's,\/opt,'"$PREFIX"',g' $DEST/.autorun

#Create installation script to install Python modules.
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


#Create $PREFIX/etc/profile
mkdir -p $DEST/tmp
cd $DEST/etc

echo "#!/bin/sh" > profile
echo "" >> profile
echo "# Please note it's not a system-wide settings, it's only for a current" >> profile
echo "# terminal session. Point your f\w (if necessery) to execute $PREFIX/etc/profile" >> profile
echo "# at console logon." >> profile
echo "" >> profile

if [ $PREFIX = "/opt" ];
then
	echo "export PATH='/opt/usr/sbin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'" >> profile
else
	echo "export PATH='$PREFIX/sbin:$PREFIX/bin:/opt/usr/sbin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'" >> profile
fi

echo "export TERM=xterm" >> profile
echo "export TMP=$PREFIX/tmp" >> profile
echo "export TEMP=$PREFIX/tmp" >> profile
echo "export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig" >> profile
echo "export M4=$PREFIX/bin/m4" >> profile
echo "" >> profile
echo "# You may define localization" >> profile
echo "#export LANG='ru_RU.UTF-8'" >> profile
echo "#export LC_ALL='ru_RU.UTF-8'" >> profile
echo "" >> profile
echo "alias ls='ls --color'" >> profile
echo "alias uptime='/usr/bin/uptime'" >> profile

chmod +x profile


#Create tarball of the compiled project.
cd $BASE$PREFIX
tar zvcf $BASE$PREFIX.tgz bin/ docs/ etc/ include/ lib/ libexec/ man/ python_modules/ sbin/ share/ ssl/ tmp/ var/ .autorun .vimrc

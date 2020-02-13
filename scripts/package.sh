#!/bin/bash

set -e
set -x

BASE=`pwd`
DEST=$BASE$PREFIX
SRC=$BASE/src

#Copy lib and include files from toolchain for use in the deployment system.
if [ "$DESTARCH" = "mipsel" ];
then
	cp -rf /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/include $DEST
	cp -rf /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/lib $DEST
fi

if [ "$DESTARCH" = "arm" ];
then
	USR=usr/
	ARM=arm-buildroot-linux-uclibcgnueabi/
        cp -rf /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/usr/arm-buildroot-linux-uclibcgnueabi/sysroot/lib $DEST
        cp -rf /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/usr/arm-buildroot-linux-uclibcgnueabi/sysroot/usr $DEST
	cp -rf $DEST/usr/include $DEST
	rm -rf $DEST/usr/include
	ln -s $PREFIX/usr/lib/crt1.o $DEST/lib/crt1.o
	ln -s $PREFIX/usr/lib/crti.o $DEST/lib/crti.o
	ln -s $PREFIX/usr/lib/crtn.o $DEST/lib/crtn.o
	ln -s $PREFIX/usr/lib/Scrt1.o $DEST/lib/Scrt1.o

	ln -s $PREFIX/usr/lib/libstdc++.so.6.0.20 $DEST/lib/libstdc++.so.6.0.20
	ln -s $PREFIX/usr/lib/libstdc++.so.6.0.20 $DEST/lib/libstdc++.so.6
	ln -s $PREFIX/usr/lib/libstdc++.so.6.0.20 $DEST/lib/libstdc++.so
fi

#Remove build path directory $BASE from all libtool .la files.
#This makes sure the libtool files show the correct paths to libraries for the deployment system.
find $DEST/lib -iname \*.la -exec sed -i 's,'"$BASE"',,g' {} \;

#Change the base library libtool (.la) files to reference their correct location in the target system.
find $DEST/lib -iname \*.la -exec sed -i 's,\/opt\/tomatoware\/'"$DESTARCH"'-'"$FLOAT"''"${PREFIX////-}"'/'"$DESTARCH"'-linux-uclibc,'"$PREFIX"',g' {} \;

#Make sure all perl scripts have the correct interpreter path.
grep -Irl "\#\!\/usr\/bin\/perl" $DEST | xargs sed -i -e '1,1s,\#\!\/usr\/bin\/perl,\#\!'"$PREFIX"'\/bin\/perl,g'
grep -Irl "\#\! \/usr\/bin\/perl" $DEST | xargs sed -i -e '1,1s,\#\! \/usr\/bin\/perl,\#\! '"$PREFIX"'\/bin\/perl,g'

#Make sure all bash scripts have the correct interpreter path.
grep -Irl "\#\!\/bin\/bash" $DEST | xargs sed -i -e '1,1s,\#\!\/bin\/bash,\#\!'"$PREFIX"'\/bin\/bash,g'
grep -Irl "\#\! \/bin\/bash" $DEST | xargs sed -i -e '1,1s,\#\! \/bin\/bash,\#\! '"$PREFIX"'\/bin\/bash,g'

#Set correct path in gnutls script.
if [ -f $DEST/bin/libgnutls-config ]; then
	sed -i 's,\/bin\/bash,'"$PREFIX"'\/bin\/bash,g' $DEST/bin/libgnutls-config
fi

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
	cp $BASE/src/markdown/Markdown.tar.gz .
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
echo "rm -rf Markdown" >> install_modules.sh
echo "tar zxvf Markdown.tar.gz" >> install_modules.sh
echo "cd Markdown/" >> install_modules.sh
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
echo "export TERMINFO=$PREFIX/share/terminfo" >> profile
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

chmod +x profile

#Create tarball of the compiled project.
cd $BASE$PREFIX
tar zvcf $BASE/$DESTARCH-$FLOAT${PREFIX////-}.tgz $ARM bin/ docs/ etc/ include/ lib/ libexec/ man/ python_modules/ sbin/ share/ ssl/ tmp/ $USR var/ .autorun .vimrc

#!/bin/bash

set -e
set -x

BASE=`pwd`
DEST=$BASE$PREFIX
SRC=$BASE/src

if [ -f $BASE/.packaged ]; then
exit
fi

if [ "$DESTARCH" = "arm" ]; then
        GNUEABI=gnueabi

	# copy golang build script for arm builds
	mkdir -p $DEST/scripts
	cp $SRC/golang/build_go.sh $DEST/scripts
	sed -i 's,\/mmc,'"$PREFIX"',g' $DEST/scripts/build_go.sh
	SCRIPTS=scripts
fi

#Copy lib and include files from toolchain for use in the deployment system.
cp -rf /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/usr/$DESTARCH-buildroot-linux-uclibc$GNUEABI/sysroot/lib $DEST
cp -rf /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/usr/$DESTARCH-buildroot-linux-uclibc$GNUEABI/sysroot/usr $DEST
cp -rf $DEST/usr/include $DEST
rm -rf $DEST/usr/include
ln -sf $PREFIX/usr/lib/crt1.o $DEST/lib/crt1.o
ln -sf $PREFIX/usr/lib/crti.o $DEST/lib/crti.o
ln -sf $PREFIX/usr/lib/crtn.o $DEST/lib/crtn.o
ln -sf $PREFIX/usr/lib/Scrt1.o $DEST/lib/Scrt1.o

ln -sf $PREFIX/usr/lib/libstdc++.so.6.0.25 $DEST/lib/libstdc++.so.6.0.25
ln -sf $PREFIX/usr/lib/libstdc++.so.6.0.25 $DEST/lib/libstdc++.so.6
ln -sf $PREFIX/usr/lib/libstdc++.so.6.0.25 $DEST/lib/libstdc++.so

#Remove build path directory $BASE from all libtool .la files.
#This makes sure the libtool files show the correct paths to libraries for the deployment system.
find $DEST/lib -iname \*.la -exec sed -i 's,'"$BASE"',,g' {} \;

#Change the base library libtool (.la) files to reference their correct location in the target system.
find $DEST/lib -iname \*.la -exec sed -i 's,\/opt\/tomatoware\/'"$DESTARCH"'-'"$FLOAT"''"${PREFIX////-}"'\/'"$DESTARCH"'-linux-uclibc,'"$PREFIX"',g' {} \;

#Make sure all perl scripts have the correct interpreter path.
grep -Irl "\#\!\/usr\/bin\/perl" $DEST | xargs sed -i -e '1,1s,\#\!\/usr\/bin\/perl,\#\!'"$PREFIX"'\/bin\/perl,g'
grep -Irl "\#\! \/usr\/bin\/perl" $DEST | xargs sed -i -e '1,1s,\#\! \/usr\/bin\/perl,\#\! '"$PREFIX"'\/bin\/perl,g'

#Make sure all bash scripts have the correct interpreter path.
grep -Irl "\#\!\/bin\/bash" $DEST | xargs sed -i -e '1,1s,\#\!\/bin\/bash,\#\!'"$PREFIX"'\/bin\/bash,g'
grep -Irl "\#\! \/bin\/bash" $DEST | xargs sed -i -e '1,1s,\#\! \/bin\/bash,\#\! '"$PREFIX"'\/bin\/bash,g'

#Set corect M4 path in autom4te & autoupdate
sed -i 's,\/opt\/tomatoware\/'"$DESTARCH"'-'"$FLOAT"''"${PREFIX////-}"'\/usr\/bin\/\/m4,'"$PREFIX"'\/bin\/m4,g' $DEST/bin/autom4te $DEST/bin/autoupdate

#Copy and set correct interpreter path for the .autorun file
cp $SRC/.autorun $DEST
sed -i 's,\/opt,'"$PREFIX"',g' $DEST/.autorun


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
	echo "export PATH='/opt/usr/sbin:/opt/sbin:/opt/bin:/opt/bin/go/bin:/opt/go/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'" >> profile
else
	echo "export PATH='$PREFIX/sbin:$PREFIX/bin:$PREFIX/bin/go/bin:$PREFIX/go/bin:/opt/usr/sbin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'" >> profile
fi

echo "export TERM=xterm" >> profile
echo "export TERMINFO=$PREFIX/share/terminfo" >> profile
echo "export TMP=$PREFIX/tmp" >> profile
echo "export TEMP=$PREFIX/tmp" >> profile
echo "export TMPDIR=$PREFIX/tmp" >> profile
echo "export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig" >> profile
echo "export CONFIG_SHELL=$PREFIX/bin/bash" >> profile
echo "export M4=$PREFIX/bin/m4" >> profile
echo "export GOPATH=$PREFIX/go" >> profile
echo "" >> profile
echo "# An influential go environment variable for creating static binaries." >> profile
echo "# Build static by default." >> profile
echo "export CGO_ENABLED=0" >> profile
echo "" >> profile
echo "# You may define localization" >> profile
echo "#export LANG='ru_RU.UTF-8'" >> profile
echo "#export LC_ALL='ru_RU.UTF-8'" >> profile
echo "" >> profile
echo "alias ls='ls --color'" >> profile

chmod +x profile

#Create tarball of the compiled project.
cd $BASE$PREFIX
chmod 1777 tmp/

fakeroot-tcp tar zvcf $BASE/$DESTARCH-$FLOAT${PREFIX////-}.tgz $DESTARCH-buildroot-linux-uclibc$GNUEABI bin/ docs/ etc/ include/ lib/ libexec/ man/ sbin/ $SCRIPTS share/ ssl/ tmp/ usr/ var/ .autorun .vimrc
touch $BASE/.packaged

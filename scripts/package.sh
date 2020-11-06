#!/bin/bash

source ./scripts/environment.sh

if [ -f $BASE/.packaged ]; then
exit
fi

if [ ! -f $BASE/.configured ]; then

#Copy lib and include files from toolchain for use in the deployment system.
cp -rf /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/sysroot/lib $DEST
cp -rf /opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/sysroot/usr $DEST
cp -rf $DEST/usr/include $DEST
rm -rf $DEST/usr/include
ln -sf ../include $DEST/usr/include

#Add include paths for clang to find things
ln -sf ./$DESTARCH-tomatoware-linux-uclibc$GNUEABI/$GCC_VERSION/include/c++/ $DEST/lib/gcc/c++
ln -sf ./$DESTARCH-tomatoware-linux-uclibc$GNUEABI/$GCC_VERSION/include/c++/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/ $DEST/lib/gcc/c++2

if [ "$DESTARCH" = "arm" ]; then
	ln -sf ./gcc/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/$GCC_VERSION/libgo.so.16.0.0 $DEST/lib/libgo.so.16.0.0
	ln -sf ./gcc/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/$GCC_VERSION/libgo.so.16.0.0 $DEST/lib/libgo.so.16
	ln -sf ./gcc/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/$GCC_VERSION/libgo.so.16.0.0 $DEST/lib/libgo.so
fi

#Remove build path directory $BASE from all libtool .la files.
#This makes sure the libtool files show the correct paths to libraries for the deployment system.
find $DEST/lib -iname \*.la -exec sed -i 's,'"$BASE"',,g' {} \;

#Change the base library libtool (.la) files to reference their correct location in the target system.
find $DEST/lib -iname \*.la -exec sed -i 's,\/opt\/tomatoware\/'"$DESTARCH"'-'"$FLOAT"''"${PREFIX////-}"'\/'"$DESTARCH"'-linux-uclibc,'"$PREFIX"',g' {} \;

#Remove build path directory $BASE from all pkg-config .pc files.
#This makes sure the pkg-config .pc files show the correct paths to libraries for the deployment system.
find $DEST/lib/pkgconfig -iname \*.pc -exec sed -i 's,'"$DEST"','"$PREFIX"',g' {} \;

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
cp $SRC/bash/profile $DEST/etc
sed -i 's,\/mmc,'"$PREFIX"',g' $DEST/etc/profile

#Create tmp directory
mkdir -p $DEST/tmp
chmod 1777 $DEST/tmp/

touch $BASE/.configured
fi

#Create tarball of the compiled project.
cd $BASE$PREFIX
rm -f $BASE/$DESTARCH-$FLOAT${PREFIX////-}.tgz
fakeroot-tcp tar zvcf $BASE/$DESTARCH-$FLOAT${PREFIX////-}.tgz $DESTARCH-tomatoware-linux-uclibc$GNUEABI $MIPSEL bin/ docs/ etc/ include/ lib/ libexec/ man/ sbin/ share/ ssl/ tmp/ usr/ var/ .autorun .vimrc
touch $BASE/.packaged

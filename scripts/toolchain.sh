#!/bin/bash

source ./scripts/environment.sh

export BASE=$BASE
export SRC=$SRC

UCLIBCVER="1.0.36"
BUILDROOTVER="git"
TOOLCHAINDIR="/opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}"
MIPSELTOOLCHAINDIR="/opt/tomatoware/mipsel-$FLOAT${PREFIX////-}"


if [ ! -d /opt/tomatoware ]; then

	sudo mkdir -p /opt/tomatoware
	sudo chmod -R 777 /opt/tomatoware
fi


if [ -f $TOOLCHAINDIR/bin/$DESTARCH-linux-gcc ]; then

	UCLIBCTEST="$(find $TOOLCHAINDIR -name "libuClibc*" -exec basename {} \;)"
	UCLIBCTEST=${UCLIBCTEST#libuClibc-}
	UCLIBCTEST=${UCLIBCTEST%.so}
	GCCTEST="$($TOOLCHAINDIR/bin/$DESTARCH-linux-gcc -dumpversion)"

	if [ "$GCCTEST" != "$GCC_VERSION" ] || [ "$UCLIBCTEST" != "$UCLIBCVER" ]; then

		echo "WARNING: Out of date $DESTARCH toolchain detected. Please run \"make toolchain-clean\" and re-run to create new toolchain."
		exit 1
	fi
fi

# for cross-gcc
if [ "$DESTARCH" == "arm" ] && [ "$BUILDCROSSTOOLS" == "1" ]; then

	if [ -f $MIPSELTOOLCHAINDIR/bin/mipsel-linux-gcc ]; then

		UCLIBCTEST="$(find $MIPSELTOOLCHAINDIR -name "libuClibc*" -exec basename {} \;)"
		UCLIBCTEST=${UCLIBCTEST#libuClibc-}
		UCLIBCTEST=${UCLIBCTEST%.so}
		GCCTEST="$($MIPSELTOOLCHAINDIR/bin/mipsel-linux-gcc -dumpversion)"

		if [ "$GCCTEST" != "$GCC_VERSION" ] || [ "$UCLIBCTEST" != "$UCLIBCVER" ]; then

			echo "WARNING: Out of date mipsel toolchain detected. This is needed for $DESTARCH cross-gcc. Please compile an up-to-date toolchain for mipsel first."
			exit 1
		fi
	else
		echo "mipsel toolchain not detected. This is needed for $DESTARCH cross-gcc Please compile an up-to-date toolchain for mipsel first."
		exit 1
	fi

fi


if [ ! -f $TOOLCHAINDIR/bin/$DESTARCH-linux-gcc ]; then
	mkdir $BASE/toolchain
	tar xvjf $SRC/toolchain/buildroot-${BUILDROOTVER}.tar.bz2 -C $BASE/toolchain

	if [ "$DESTARCH" == "arm" ]; then
		patch -d $BASE/toolchain/buildroot-${BUILDROOTVER} -p1 < $PATCHES/buildroot/buildroot.patch
	fi

	cp $SRC/toolchain/defconfig.$DESTARCH $BASE/toolchain/buildroot-${BUILDROOTVER}/defconfig
	cp -r $SRC/toolchain/patches $BASE/toolchain
	mv $BASE/toolchain/patches/linux-headers.$DESTARCH $BASE/toolchain/patches/linux-headers
	echo "UCLIBC_HAS_BACKTRACE=y" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
	echo "UCLIBC_HAS_FTS=y" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
	if [ "$DESTARCH" == "mipsel" ];then
		echo "# UCLIBC_USE_MIPS_PREFETCH is not set" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
	fi
	sed -i 's,\/mmc,'"$PREFIX"',g' \
	$BASE/toolchain/patches/uclibc/001-uclibc-ldso-search-path.patch \
	$BASE/toolchain/patches/uclibc/002-uclibc-ldconfig-opt.patch \
	$BASE/toolchain/patches/uclibc/003-uclibc-dl-defs.patch \
	$BASE/toolchain/patches/uclibc/004-uclibc-ldd-opt.patch

	cd $BASE/toolchain/buildroot-${BUILDROOTVER}
	make defconfig BR2_DEFCONFIG=defconfig
	make

fi

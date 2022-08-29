#!/bin/bash

source ./scripts/environment.sh

export BASE=$BASE
export SRC=$SRC

UCLIBCVER="1.0.42"
MUSLVER="1.2.3"
BUILDROOTVER="git"
TOOLCHAINDIR="/opt/tomatoware/$DESTARCH$FLOAT${PREFIX////-}"
MIPSELTOOLCHAINDIR="/opt/tomatoware/mipsel$FLOAT${PREFIX////-}"


if [ ! -d /opt/tomatoware ]; then

	sudo mkdir -p /opt/tomatoware
	sudo chmod -R 777 /opt/tomatoware
fi


if [ -f $TOOLCHAINDIR/bin/$DESTARCH-linux-gcc ] && [ "$DESTARCHLIBC" == "uclibc" ]; then

	UCLIBCTEST="$(find $TOOLCHAINDIR -name "libuClibc*" -exec basename {} \;)"
	UCLIBCTEST=${UCLIBCTEST#libuClibc-}
	UCLIBCTEST=${UCLIBCTEST%.so}
	GCCTEST="$($TOOLCHAINDIR/bin/$DESTARCH-linux-gcc -dumpversion)"

	if [ "$GCCTEST" != "$GCC_VERSION" ] || [ "$UCLIBCTEST" != "$UCLIBCVER" ]; then

		echo "Error: Out of date $DESTARCH toolchain detected. Please run \"make toolchain-clean\" and re-run to create new toolchain."
		exit 1
	fi
fi

# for cross-gcc
if [ "$DESTARCH" == "arm" ] && [ "$BUILDCROSSTOOLS" == "1" ] && [ "$DESTARCHLIBC" == "uclibc" ]; then

	if [ -f $MIPSELTOOLCHAINDIR/bin/mipsel-linux-gcc ]; then

		UCLIBCTEST="$(find $MIPSELTOOLCHAINDIR -name "libuClibc*" -exec basename {} \;)"
		UCLIBCTEST=${UCLIBCTEST#libuClibc-}
		UCLIBCTEST=${UCLIBCTEST%.so}
		GCCTEST="$($MIPSELTOOLCHAINDIR/bin/mipsel-linux-gcc -dumpversion)"

		if [ "$GCCTEST" != "$GCC_VERSION" ] || [ "$UCLIBCTEST" != "$UCLIBCVER" ]; then

			echo "Error: Out of date mipsel toolchain detected. This is needed for $DESTARCH cross-gcc. Please compile an up-to-date toolchain for mipsel first or disable cross-gcc by setting \"BUILDCROSSTOOLS\" to \"0\" in config.mk."
			exit 1
		fi
	else
		echo "Error: mipsel toolchain not detected. This is needed for $DESTARCH cross-gcc. Please compile an up-to-date toolchain for mipsel first or disable cross-gcc by setting \"BUILDCROSSTOOLS\" to \"0\" in config.mk."
		exit 1
	fi

fi


if [ ! -f $TOOLCHAINDIR/bin/$DESTARCH-linux-gcc ]; then

	echo -e '\033]2;'Building Toolchain'\007'

	mkdir $BASE/toolchain
	tar xvjf $SRC/toolchain/buildroot-${BUILDROOTVER}.tar.bz2 -C $BASE/toolchain

	if [ "$DESTARCHLIBC" == "uclibc" ]; then
		patch -d $BASE/toolchain/buildroot-${BUILDROOTVER} -p1 < $PATCHES/buildroot/buildroot.patch
	fi

	cp $SRC/toolchain/defconfig.$DESTARCH $BASE/toolchain/buildroot-${BUILDROOTVER}/defconfig
	cp -r $SRC/toolchain/patches $BASE/toolchain
	mv $BASE/toolchain/patches/linux-headers.$DESTARCH $BASE/toolchain/patches/linux-headers
	echo "UCLIBC_HAS_BACKTRACE=y" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
	echo "UCLIBC_HAS_FTS=y" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
	echo "STATIC_PIE=y" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config

	if [ "$DESTARCH" == "mipsel" ];then
		echo "# UCLIBC_USE_MIPS_PREFETCH is not set" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
		cp $BASE/patches/gcc/0001-fix-libgo-mips-syscall.patch \
		   $BASE/patches/gcc/0002-go-runtime-mips-epoll-fix.patch \
		   $BASE/toolchain/buildroot-${BUILDROOTVER}/package/gcc/${GCC_VERSION}
	fi

	if [ "$DESTARCH" == "arm" ] || [ "$DESTARCH" == "aarch64" ];then
		rm $BASE/toolchain/patches/uclibc/007-uclibc-remove-prlimit.patch
	fi

	cp $BASE/patches/gcc/0004-libstdc-condition-variable.patch $BASE/toolchain/buildroot-${BUILDROOTVER}/package/gcc/${GCC_VERSION}
	cp $BASE/patches/gcc/0005-arm-static-pie.patch $BASE/toolchain/buildroot-${BUILDROOTVER}/package/gcc/${GCC_VERSION}
	cp $BASE/patches/gcc/0006-mips-static-pie.patch $BASE/toolchain/buildroot-${BUILDROOTVER}/package/gcc/${GCC_VERSION}

	sed -i 's,\/mmc,'"$PREFIX"',g' \
	$BASE/toolchain/patches/uclibc/001-uclibc-ldso-search-path.patch \
	$BASE/toolchain/patches/uclibc/002-uclibc-ldconfig-opt.patch \
	$BASE/toolchain/patches/uclibc/003-uclibc-dl-defs.patch \
	$BASE/toolchain/patches/uclibc/004-uclibc-ldd-opt.patch \
	$BASE/toolchain/patches/uclibc/008-utils.patch

	cd $BASE/toolchain/buildroot-${BUILDROOTVER}
	make defconfig BR2_DEFCONFIG=defconfig
	make

	if [ "$DESTARCHLIBC" == "uclibc" ]; then
		# Copy uclibc-ng utils to toolchain
		cp $BASE/toolchain/buildroot-${BUILDROOTVER}/output/target/usr/bin/* /opt/tomatoware/$DESTARCH$FLOAT${PREFIX////-}/$DESTARCH-tomatoware-linux-uclibc$GNUEABI/sysroot/bin
	fi
fi

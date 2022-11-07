#!/bin/bash

source ./scripts/environment.sh

export BASE=$BASE
export SRC=$SRC

MUSLVER="1.2.3"
UCLIBCVER="1.0.42"
BUILDROOTVER="git"
TOOLCHAINDIR="/opt/tomatoware/$DESTARCH-$DESTARCHLIBC${PREFIX////-}"
MIPSELTOOLCHAINDIR="/opt/tomatoware/mipsel-uclibc${PREFIX////-}"


if [ ! -d /opt/tomatoware ]; then

	sudo mkdir -p /opt/tomatoware
	sudo chmod -R 777 /opt/tomatoware
fi

# Test for toolchain up-to-date.
if [ -f $TOOLCHAINDIR/bin/$DESTARCH-linux-gcc ]; then

	MESSAGE="Error: Out of date $DESTARCH toolchain detected. First run \"make toolchain-clean\" and then \"make\""

	GCCTEST="$($TOOLCHAINDIR/bin/$DESTARCH-linux-gcc -dumpversion)"
	if [ "$GCCTEST" != "$GCC_VERSION" ]; then
		echo "$MESSAGE"
		exit 1
	fi

	if [ "$DESTARCHLIBC" == "uclibc" ]; then

		UCLIBCTEST="$(find $TOOLCHAINDIR -name "libuClibc*" -exec basename {} \;)"
		UCLIBCTEST=${UCLIBCTEST#libuClibc-}
		UCLIBCTEST=${UCLIBCTEST%.so}

		if [ "$UCLIBCTEST" != "$UCLIBCVER" ]; then
			echo "$MESSAGE"
			exit 1
		fi
	fi

	if [ "$DESTARCHLIBC" == "musl" ]; then

		MUSLTEST="$(cat $TOOLCHAINDIR/version)"

		if [ "$MUSLTEST" != "$MUSLVER" ]; then
			echo "$MESSAGE"
			exit 1
		fi
	fi
fi

# Test for cross-toolchain up-to-date.
if [ "$DESTARCH" == "arm" ] && [ "$DESTARCHLIBC" == "uclibc" ] && [ "$BUILDCROSSTOOLS" == "1" ]; then

	MESSAGE="This is needed for $DESTARCH cross-gcc. First compile an up-to-date mipsel toolchain or disable cross-gcc by setting \"BUILDCROSSTOOLS\" to \"0\" in config.mk."

	if [ -f $MIPSELTOOLCHAINDIR/bin/mipsel-linux-gcc ]; then

		UCLIBCTEST="$(find $MIPSELTOOLCHAINDIR -name "libuClibc*" -exec basename {} \;)"
		UCLIBCTEST=${UCLIBCTEST#libuClibc-}
		UCLIBCTEST=${UCLIBCTEST%.so}
		GCCTEST="$($MIPSELTOOLCHAINDIR/bin/mipsel-linux-gcc -dumpversion)"

		if [ "$GCCTEST" != "$GCC_VERSION" ] || [ "$UCLIBCTEST" != "$UCLIBCVER" ]; then

			echo "Error: Out of date mipsel toolchain detected. $MESSAGE"
			exit 1
		fi
	else
		echo "Error: mipsel toolchain not detected. $MESSAGE"
		exit 1
	fi
fi


if [ ! -f $TOOLCHAINDIR/bin/$DESTARCH-linux-gcc ]; then

	echo -e '\033]2;'Building Toolchain'\007'

	mkdir $BASE/toolchain
	tar xvjf $SRC/toolchain/buildroot-${BUILDROOTVER}.tar.bz2 -C $BASE/toolchain

	if [[ ! ("$DESTARCH" == "arm" && "$DESTARCHLIBC" == "musl") ]] && [ "$DESTARCH" != "x86_64" ]; then
		patch -d $BASE/toolchain/buildroot-${BUILDROOTVER} -p1 < $PATCHES/buildroot/golang.patch
	fi

	if [ "$DESTARCH" == "arm" ]; then
		cp $SRC/toolchain/defconfig.$DESTARCH.$DESTARCHLIBC $BASE/toolchain/buildroot-${BUILDROOTVER}/defconfig
	else
		cp $SRC/toolchain/defconfig.$DESTARCH $BASE/toolchain/buildroot-${BUILDROOTVER}/defconfig
	fi

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

	if [ "$DESTARCH" == "arm" ];then
		rm $BASE/toolchain/patches/uclibc/007-uclibc-remove-prlimit.patch

		if [ "$DESTARCHLIBC" == "musl" ]; then
			cp $PATCHES/musl/arm-musl.patch $BASE/toolchain/patches/musl/
		fi
	fi

	if [ "$DESTARCH" == "aarch64" ];then

		cp $BASE/patches/gcc/musl/musl-compat.patch \
		   $BASE/patches/gcc/musl/0030-gcc-go-Fix-handling-of-signal-34-on-musl.patch \
		   $BASE/patches/gcc/musl/0032-gcc-go-undef-SETCONTEXT_CLOBBERS_TLS-in-proc.c.patch \
		   $BASE/patches/gcc/musl/0034-Use-generic-errstr.go-implementation-on-musl.patch \
		   $BASE/patches/gcc/musl/0037-libgo-Recognize-off64_t-and-loff_t-definitions-of-mu.patch \
		   $BASE/patches/gcc/musl/0039-gcc-go-Use-int64-type-as-offset-argument-for-mmap.patch \
		   $BASE/patches/gcc/musl/0041-go-gospec-forcibly-disable-fsplit-stack-support.patch \
		   $BASE/patches/gcc/musl/0042-gcc-go-fix-build-error-with-SYS_SECCOMP.patch \
		   $BASE/patches/gcc/musl/0049-libgo-adjust-name-of-union-in-sigevent-struct.patch \
		   $BASE/patches/gcc/musl/0051-libgo-Explicitly-define-SYS_timer_settime-for-32-bit.patch \
		   $BASE/patches/gcc/musl/0053-libgo-make-match.sh-POSIX-shell-compatible.patch \
		   $BASE/toolchain/buildroot-${BUILDROOTVER}/package/gcc/${GCC_VERSION}
#		   $BASE/patches/gcc/musl/0033-gcc-go-link-to-libucontext.patch \
	fi
	mkdir -p $BASE/toolchain/buildroot-${BUILDROOTVER}/package/gcc/${GCC_VERSION}
	cp $BASE/patches/gcc/0004-libstdc-condition-variable.patch \
	   $BASE/patches/gcc/0005-arm-static-pie.patch \
	   $BASE/patches/gcc/0006-mips-static-pie.patch \
	   $BASE/toolchain/buildroot-${BUILDROOTVER}/package/gcc/${GCC_VERSION}

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
		cp $BASE/toolchain/buildroot-${BUILDROOTVER}/output/target/usr/bin/* /opt/tomatoware/$DESTARCH-$DESTARCHLIBC${PREFIX////-}/$DESTARCH-tomatoware-linux-uclibc$EABI/sysroot/bin
	fi

	if [ "$DESTARCHLIBC" == "musl" ]; then
		echo "$MUSLVER" > $TOOLCHAINDIR/version
	fi

	if [[ "$DESTARCH" == "aarch64" || "$DESTARCH" == "x86_64" ]]; then

		LIBUCONTEXT_VERSION=1.2

		cd $SRC/libucontext

		if [ ! -f .extracted ]; then
			rm -rf libucontext libucontext-${LIBUCONTEXT_VERSION}
			tar xvJf libucontext-${LIBUCONTEXT_VERSION}.tar.xz
			mv libucontext-${LIBUCONTEXT_VERSION} libucontext
			touch .extracted
		fi

		cd libucontext

		if [ ! -f .built ]; then
			$MAKE1 \
			ARCH=$DESTARCH \
			CC=`which $DESTARCH-linux-gcc` \
			AR=`which $DESTARCH-linux-ar`
			touch .built
		fi

		if [ ! -f .installed ]; then
			$MAKE1 \
			ARCH=$DESTARCH \
			CC=`which $DESTARCH-linux-gcc` \
			AR=`which $DESTARCH-linux-ar` \
			DESTDIR=/opt/tomatoware/$DESTARCH-$DESTARCHLIBC${PREFIX////-}/$DESTARCH-tomatoware-linux-$DESTARCHLIBC$EABI/sysroot \
			install
			touch .installed
		fi
	fi
fi

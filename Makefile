ARCH=mipsel
export DESTARCH=$(ARCH)
export PREFIX=/opt

ifeq ($(DESTARCH), mipsel)
	export EXTRACFLAGS=-mtune=mips32 -mips32
endif

ifeq ($(DESTARCH), arm)
        export EXTRACFLAGS=
endif

export PATH := $(PATH):/opt/entware-toolchain-$(DESTARCH)$(subst /,-,$(PREFIX))/bin/:/opt/entware-toolchain-$(DESTARCH)$(subst /,-,$(PREFIX))/mipsel-linux/bin

tomatoware:
	./scripts/toolchain.sh
	./scripts/install.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

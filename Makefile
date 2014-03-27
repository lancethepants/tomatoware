export PREFIX=/opt
export DESTARCH=mipsel

export EXTRACFLAGS=-mtune=mips32 -mips32

export PATH := $(PATH):/opt/entware-toolchain-$(subst /,,$(PREFIX))/bin/:/opt/entware-toolchain-$(subst /,,$(PREFIX))/mipsel-linux/bin

tomatoware:
	./scripts/toolchain.sh
	./scripts/install.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

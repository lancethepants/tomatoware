include config.mk

tomatoware:toolchain
	./scripts/base.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

toolchain:
	./scripts/toolchain.sh

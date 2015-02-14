include config.mk

tomatoware:
	./scripts/toolchain.sh
	./scripts/base.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

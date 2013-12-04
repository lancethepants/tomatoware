SHELL := /bin/bash

export PREFIX=/opt

export BASE = $(PWD)
export SRC = $(BASE)/src
export PATCHES = $(BASE)/patches
export RPATH = $(PREFIX)/lib
export DEST = $(BASE)$(PREFIX)
export LDFLAGS = -L$(DEST)/lib -s -Wl,--dynamic-linker=$(PREFIX)/lib/ld-uClibc.so.0 -Wl,-rpath,$(RPATH) -Wl,-rpath-link,$(DEST)/lib
export CPPFLAGS = -I$(DEST)/include -I$(DEST)/include/ncurses
export CFLAGS = -mtune=mips32 -mips32
export CXXFLAGS = $(CFLAGS)
export CONFIGURE = ./configure --prefix=$(PREFIX) --host=mipsel-linux
export MAKE = make -j$(shell nproc)

tomatoware:
	./scripts/toolchain.sh
	./scripts/install.sh
	./scripts/buildroot.sh
	./scripts/asterisk.sh
	./scripts/package.sh

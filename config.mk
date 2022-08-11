# User Configurable Options

export DESTARCH ?= aarch64
#export DESTARCH ?= arm
#export DESTARCH ?= mipsel

export PREFIX ?= /mmc
#export PREFIX ?= /mnt

# Only Supported For Arm
export BUILDLLVM ?= 1
export BUILDCROSSTOOLS ?= 1

# Do Not Edit

ifeq ($(DESTARCH), mipsel)
export FLOAT=-soft
export DESTARCHLIBC = uclibc
export EXTRACFLAGS = -O2 -pipe -mips32 -mtune=mips32
endif

ifeq ($(DESTARCH), arm)
export FLOAT=-soft
export DESTARCHLIBC = uclibc
export EXTRACFLAGS = -O2 -pipe -march=armv7-a -mtune=cortex-a9
endif

ifeq ($(DESTARCH), aarch64)
export DESTARCHLIBC = musl
export EXTRACFLAGS = -mcpu=cortex-a53
endif

export PATH := $(PATH):/opt/tomatoware/mipsel$(FLOAT)$(subst /,-,$(PREFIX))/bin/
export PATH := $(PATH):/opt/tomatoware/arm$(FLOAT)$(subst /,-,$(PREFIX))/bin/
export PATH := $(PATH):/opt/tomatoware/aarch64$(subst /,-,$(PREFIX))/bin/

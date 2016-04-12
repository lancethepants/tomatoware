# User Configurable Options

export DESTARCH ?= arm
#export DESTARCH ?= mipsel

export PREFIX ?= /mmc
#export PREFIX ?= /mnt

# Do Not Edit

export FLOAT=soft
export PATH := /opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))/usr/bin/:$(PATH)

ifeq ($(DESTARCH), arm)
export EXTRACFLAGS = -O2 -pipe -march=armv7-a -mtune=cortex-a9
endif

ifeq ($(DESTARCH), mipsel)
export EXTRACFLAGS = -O2 -pipe -mips32 -mtune=mips32
endif


# User Configurable Options

export DESTARCH ?= arm
#export DESTARCH ?= mipsel

export PREFIX ?= /mmc
#export PREFIX ?= /mnt

export BUILDCROSSTOOLS ?= 1

# Do Not Edit

export FLOAT=soft

ifeq ($(DESTARCH), arm)
export EXTRACFLAGS = -O2 -pipe -march=armv7-a -mtune=cortex-a9

#For cross-gcc
export PATH := /opt/tomatoware/mipsel-$(FLOAT)$(subst /,-,$(PREFIX))/bin/:$(PATH)
endif

ifeq ($(DESTARCH), mipsel)
export EXTRACFLAGS = -O2 -pipe -mips32 -mtune=mips32
endif

export PATH := /opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))/bin/:$(PATH)

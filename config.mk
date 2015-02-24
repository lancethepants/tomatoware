# User Configurable Options

export DESTARCH=mipsel
#export DESTARCH=arm

export PREFIX=/mmc
#export PREFIX=/jffs
#export PREFIX=/opt/tomatoware
#export PREFIX=/opt

# Do Not Edit

export FLOAT=soft

ifeq ($(DESTARCH), mipsel)
export EXTRACFLAGS = -O2 -pipe -mips32 -mtune=mips32
export PATH := $(PATH):/opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))/bin/
endif

ifeq ($(DESTARCH), arm)
export EXTRACFLAGS = -O2 -pipe -march=armv7-a -mtune=cortex-a9
export PATH := $(PATH):/opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))/usr/bin/
endif

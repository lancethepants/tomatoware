export DESTARCH=mipsel
#export DESTARCH=arm

export FLOAT=soft
#export FLOAT=hard

export PREFIX=/opt
#export PREFIX=/mmc
#export PREFIX=/jffs
#export PREFIX=/opt/tomatoware

ifeq ($(DESTARCH), mipsel)
export EXTRACFLAGS = -O2 -pipe -mips32 -mtune=mips32
endif

ifeq ($(DESTARCH), arm)
export EXTRACFLAGS=
endif

export PATH := $(PATH):/opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))/bin/:/opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))/$(DESTARCH)-linux/bin

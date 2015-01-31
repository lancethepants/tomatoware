export DESTARCH=mipsel
#export DESTARCH=arm

export FLOAT=soft
#export FLOAT=hard

export PREFIX=/mmc
#export PREFIX=/jffs
#export PREFIX=/opt/tomatoware
#export PREFIX=/opt

ifeq ($(DESTARCH), mipsel)
export EXTRACFLAGS = -mips32r2 -mtune=mips32r2
endif

ifeq ($(DESTARCH), arm)
export EXTRACFLAGS=
endif

export PATH := /opt/tomatoware/$(DESTARCH)-$(FLOAT)$(subst /,-,$(PREFIX))/bin/:$(PATH)

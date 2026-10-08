################################################################################
#
# distcc
#
################################################################################

DISTCC_VERSION = 3.4
DISTCC_SITE = https://github.com/distcc/distcc/releases/download/v$(DISTCC_VERSION)
DISTCC_LICENSE = GPL-2.0+
DISTCC_LICENSE_FILES = COPYING

# Pump mode needs python at build time and the include server at run time.
DISTCC_CONF_OPTS = \
	--with-included-popt \
	--without-libiberty \
	--without-avahi \
	--without-gtk \
	--disable-pump-mode \
	--disable-Werror

# 2021 code: tentative definitions shared between objects, and declarations
# without prototypes that C23 (the default from GCC 15 on) no longer accepts.
DISTCC_CONF_ENV = CFLAGS="$(TARGET_CFLAGS) -std=gnu17 -fcommon"

$(eval $(autotools-package))

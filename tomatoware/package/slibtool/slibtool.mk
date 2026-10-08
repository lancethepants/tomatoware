################################################################################
#
# slibtool
#
################################################################################

SLIBTOOL_VERSION = 0.7.4
SLIBTOOL_SOURCE = slibtool-$(SLIBTOOL_VERSION).tar.xz
SLIBTOOL_SITE = https://dl.foss21.org/slibtool
SLIBTOOL_LICENSE = MIT
SLIBTOOL_LICENSE_FILES = COPYING.SLIBTOOL

# Not autoconf: slibtool has its own configure script.
define SLIBTOOL_CONFIGURE_CMDS
	cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
			--prefix=$(TOMATOWARE_PREFIX) \
			--host=$(GNU_TARGET_NAME) \
			--compiler=gcc
endef

define SLIBTOOL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define SLIBTOOL_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))

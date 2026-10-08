################################################################################
#
# ninja-target
#
################################################################################

# Buildroot only has ninja as a host tool, and does not allow a target variant
# to be added to an existing host package, hence the separate package. It
# builds the same version from the same tarball as package/ninja.
NINJA_TARGET_VERSION = $(NINJA_VERSION)
NINJA_TARGET_SOURCE = ninja-$(NINJA_VERSION).tar.gz
NINJA_TARGET_SITE = $(NINJA_SITE)
NINJA_TARGET_DL_SUBDIR = ninja
NINJA_TARGET_LICENSE = $(NINJA_LICENSE)
NINJA_TARGET_LICENSE_FILES = $(NINJA_LICENSE_FILES)
NINJA_TARGET_CONF_OPTS = -DBUILD_TESTING=OFF

define NINJA_TARGET_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/ninja $(TARGET_DIR)/usr/bin/ninja
endef

$(eval $(cmake-package))

NINJA_TARGET_HASH_FILES = package/ninja/ninja.hash

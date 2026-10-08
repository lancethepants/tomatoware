################################################################################
#
# automake-target
#
################################################################################

# Buildroot only has automake as a host tool, and does not allow a target variant
# to be added to an existing host package, hence the separate package. It
# builds the same version from the same tarball as package/automake.
AUTOMAKE_TARGET_VERSION = $(AUTOMAKE_VERSION)
AUTOMAKE_TARGET_SOURCE = $(AUTOMAKE_SOURCE)
AUTOMAKE_TARGET_SITE = $(AUTOMAKE_SITE)
AUTOMAKE_TARGET_DL_SUBDIR = automake
AUTOMAKE_TARGET_LICENSE = $(AUTOMAKE_LICENSE)
AUTOMAKE_TARGET_LICENSE_FILES = $(AUTOMAKE_LICENSE_FILES)
AUTOMAKE_TARGET_DEPENDENCIES = autoconf-target perl host-autoconf

# Includes the patch that stops the build generating man pages by running
# the freshly built automake.
define AUTOMAKE_TARGET_APPLY_BUILDROOT_PATCHES
	$(APPLY_PATCHES) $(@D) package/automake \*.patch
endef
AUTOMAKE_TARGET_POST_PATCH_HOOKS += AUTOMAKE_TARGET_APPLY_BUILDROOT_PATCHES

$(eval $(autotools-package))

AUTOMAKE_TARGET_HASH_FILES = package/automake/automake.hash

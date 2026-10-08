################################################################################
#
# autoconf-target
#
################################################################################

# Buildroot only has autoconf as a host tool, and does not allow a target variant
# to be added to an existing host package, hence the separate package. It
# builds the same version from the same tarball as package/autoconf.
AUTOCONF_TARGET_VERSION = $(AUTOCONF_VERSION)
AUTOCONF_TARGET_SOURCE = $(AUTOCONF_SOURCE)
AUTOCONF_TARGET_SITE = $(AUTOCONF_SITE)
AUTOCONF_TARGET_DL_SUBDIR = autoconf
AUTOCONF_TARGET_LICENSE = $(AUTOCONF_LICENSE)
AUTOCONF_TARGET_LICENSE_FILES = $(AUTOCONF_LICENSE_FILES)
AUTOCONF_TARGET_DEPENDENCIES = m4-target perl host-m4

define AUTOCONF_TARGET_APPLY_BUILDROOT_PATCHES
	$(APPLY_PATCHES) $(@D) package/autoconf \*.patch
endef
AUTOCONF_TARGET_POST_PATCH_HOOKS += AUTOCONF_TARGET_APPLY_BUILDROOT_PATCHES

# The build freezes its macro files by running m4, so it has to be configured
# with one that runs on the build machine. Same version as the m4 we ship, so
# the frozen files stay valid on the router.
AUTOCONF_TARGET_CONF_ENV = \
	EMACS="no" \
	ac_cv_path_M4=$(HOST_DIR)/bin/m4 \
	ac_cv_prog_gnu_m4_gnu=no

# Then point the installed scripts at the m4 on the router. Their perl
# interpreter line is rewritten by post-image.sh.
define AUTOCONF_TARGET_FIX_M4_PATH
	grep -rIl -- '$(HOST_DIR)/bin/m4' \
		$(TARGET_DIR)/usr/bin $(TARGET_DIR)/usr/share/autoconf | \
		xargs -r $(SED) 's,$(HOST_DIR)/bin/m4,$(TOMATOWARE_PREFIX)/bin/m4,g'
endef
AUTOCONF_TARGET_POST_INSTALL_TARGET_HOOKS += AUTOCONF_TARGET_FIX_M4_PATH

$(eval $(autotools-package))

AUTOCONF_TARGET_HASH_FILES = package/autoconf/autoconf.hash

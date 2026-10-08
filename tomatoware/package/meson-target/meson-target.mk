################################################################################
#
# meson-target
#
################################################################################

# Buildroot only has meson as a host tool, and does not allow a target variant
# to be added to an existing host package, hence the separate package. It
# builds the same version from the same tarball as package/meson. Buildroot's
# own meson patches are not applied: they adjust how the host meson picks
# libraries when cross-compiling for the target.
MESON_TARGET_VERSION = $(MESON_VERSION)
MESON_TARGET_SOURCE = meson-$(MESON_VERSION).tar.gz
MESON_TARGET_SITE = $(MESON_SITE)
MESON_TARGET_DL_SUBDIR = meson
MESON_TARGET_LICENSE = $(MESON_LICENSE)
MESON_TARGET_LICENSE_FILES = $(MESON_LICENSE_FILES)
MESON_TARGET_SETUP_TYPE = setuptools
MESON_TARGET_DEPENDENCIES = ninja-target

$(eval $(python-package))

MESON_TARGET_HASH_FILES = package/meson/meson.hash

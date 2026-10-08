################################################################################
#
# m4-target
#
################################################################################

# Buildroot only has m4 as a host tool, and does not allow a target variant
# to be added to an existing host package, hence the separate package. It
# builds the same version from the same tarball as package/m4.
M4_TARGET_VERSION = $(M4_VERSION)
M4_TARGET_SOURCE = $(M4_SOURCE)
M4_TARGET_SITE = $(M4_SITE)
M4_TARGET_DL_SUBDIR = m4
M4_TARGET_LICENSE = $(M4_LICENSE)
M4_TARGET_LICENSE_FILES = $(M4_LICENSE_FILES)

$(eval $(autotools-package))

M4_TARGET_HASH_FILES = package/m4/m4.hash

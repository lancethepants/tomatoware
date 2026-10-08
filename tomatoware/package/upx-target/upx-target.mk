################################################################################
#
# upx-target
#
################################################################################

# Buildroot only has upx as a host tool, and does not allow a target variant
# to be added to an existing host package, hence the separate package. It
# builds the same version from the same tarball as package/upx.
UPX_TARGET_VERSION = $(UPX_VERSION)
UPX_TARGET_SOURCE = $(UPX_SOURCE)
UPX_TARGET_SITE = $(UPX_SITE)
UPX_TARGET_DL_SUBDIR = upx
UPX_TARGET_LICENSE = $(UPX_LICENSE)
UPX_TARGET_LICENSE_FILES = $(UPX_LICENSE_FILES)
UPX_TARGET_SUPPORTS_IN_SOURCE_BUILD = NO

# The self-tests run the freshly built upx.
UPX_TARGET_CONF_OPTS = \
	-DUPX_CONFIG_DISABLE_SELF_PACK_TEST=ON \
	-DUPX_CONFIG_DISABLE_GITREV=ON \
	-DUPX_CONFIG_DISABLE_SANITIZE=ON \
	-DUPX_CONFIG_DISABLE_WSTRICT=ON \
	-DUPX_CONFIG_DISABLE_WERROR=ON

$(eval $(cmake-package))

UPX_TARGET_HASH_FILES = package/upx/upx.hash

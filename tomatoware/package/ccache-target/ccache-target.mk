################################################################################
#
# ccache-target
#
################################################################################

# Buildroot only has ccache as a host tool, and does not allow a target
# variant to be added to an existing host package, hence the separate package.
# It builds the same version from the same tarball as package/ccache, without
# the patches that tie the host ccache to Buildroot's cache directory.
CCACHE_TARGET_VERSION = $(CCACHE_VERSION)
CCACHE_TARGET_SOURCE = $(CCACHE_SOURCE)
CCACHE_TARGET_SITE = $(CCACHE_SITE)
CCACHE_TARGET_DL_SUBDIR = ccache
CCACHE_TARGET_LICENSE = $(CCACHE_LICENSE)
CCACHE_TARGET_LICENSE_FILES = $(CCACHE_LICENSE_FILES)
CCACHE_TARGET_DEPENDENCIES = blake3 xxhash zstd

CCACHE_TARGET_CONF_OPTS = \
	-DCCACHE_DEV_MODE=OFF \
	-DDEP_BLAKE3=SYSTEM \
	-DDEP_FMT=BUNDLED \
	-DDEP_CPPHTTPLIB=BUNDLED \
	-DDEP_NONSTDSPAN=BUNDLED \
	-DDEP_TLEXPECTED=BUNDLED \
	-DDEP_XXHASH=SYSTEM \
	-DDEP_ZSTD=SYSTEM \
	-DREDIS_STORAGE_BACKEND=OFF \
	-DENABLE_DOCUMENTATION=OFF \
	-DENABLE_TESTING=OFF

$(eval $(cmake-package))

CCACHE_TARGET_HASH_FILES = package/ccache/ccache.hash

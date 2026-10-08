################################################################################
#
# mold
#
################################################################################

MOLD_VERSION = 2.42.1
MOLD_SITE = $(call github,rui314,mold,v$(MOLD_VERSION))
MOLD_LICENSE = MIT
MOLD_LICENSE_FILES = LICENSE
MOLD_DEPENDENCIES = zlib zstd
MOLD_SUPPORTS_IN_SOURCE_BUILD = NO

# TBB, mimalloc, blake3 and xxhash are the copies bundled with mold, as
# upstream builds it.
MOLD_CONF_OPTS = \
	-DBUILD_TESTING=OFF \
	-DMOLD_USE_MOLD=OFF \
	-DMOLD_LTO=OFF

$(eval $(cmake-package))

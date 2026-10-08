################################################################################
#
# bison-target
#
################################################################################

# Buildroot only has bison as a host tool, and does not allow a target variant
# to be added to an existing host package, hence the separate package. It
# builds the same version from the same tarball as package/bison.
BISON_TARGET_VERSION = $(BISON_VERSION)
BISON_TARGET_SOURCE = $(BISON_SOURCE)
BISON_TARGET_SITE = $(BISON_SITE)
BISON_TARGET_DL_SUBDIR = bison
BISON_TARGET_LICENSE = $(BISON_LICENSE)
BISON_TARGET_LICENSE_FILES = $(BISON_LICENSE_FILES)
BISON_TARGET_DEPENDENCIES = m4-target host-m4
BISON_TARGET_MAKE = $(MAKE1)
BISON_TARGET_CONF_ENV = \
	ac_cv_path_M4=$(TOMATOWARE_PREFIX)/bin/m4 \
	ac_cv_libtextstyle=no

$(eval $(autotools-package))

BISON_TARGET_HASH_FILES = package/bison/bison.hash

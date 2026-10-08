# Buildroot only builds libltdl for the target. Build from the top of the
# tree instead, which also gives the libtool and libtoolize scripts.
LIBTOOL_SUBDIR = .
LIBTOOL_LICENSE_FILES = libltdl/COPYING.LIB
LIBTOOL_CONF_ENV += \
	HELP2MAN=true \
	MAKEINFO=true \
	lt_cv_sys_lib_dlsearch_path_spec="$(TOMATOWARE_PREFIX)/lib"

# configure records the sed and grep it found on the build machine as the
# ones the installed scripts should run.
define LIBTOOL_USE_BUNDLED_TOOLS
	$(SED) 's,"\(/usr\)\?/bin/\(sed\|grep\),"$(TOMATOWARE_PREFIX)/bin/\2,g' \
		$(TARGET_DIR)/usr/bin/libtool $(TARGET_DIR)/usr/bin/libtoolize
endef
LIBTOOL_POST_INSTALL_TARGET_HOOKS += LIBTOOL_USE_BUNDLED_TOOLS

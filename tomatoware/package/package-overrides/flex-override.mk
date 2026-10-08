# Buildroot only builds libfl for the target; we want the flex program, and
# it has to find the m4 we ship.
FLEX_DEPENDENCIES += m4-target
FLEX_CONF_ENV += ac_cv_path_M4=$(TOMATOWARE_PREFIX)/bin/m4
FLEX_CONF_OPTS += --enable-program

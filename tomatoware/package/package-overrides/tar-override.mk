# tar.mk passes --exec-prefix=/ to get the binaries into /bin.
TAR_CONF_OPTS += --exec-prefix=$(TOMATOWARE_PREFIX)

# grep.mk passes --exec-prefix=/ to get the binaries into /bin.
GREP_CONF_OPTS += --exec-prefix=$(TOMATOWARE_PREFIX)

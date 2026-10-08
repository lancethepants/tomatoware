# Without a sysroot the native ld falls back to /lib and /usr/lib, which on
# the router are the firmware's libraries, not ours.
BINUTILS_CONF_OPTS += \
	--with-sysroot=$(TOMATOWARE_PREFIX) \
	--enable-plugins

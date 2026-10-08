# procps-ng.mk passes --exec-prefix=/ and --libdir=/usr/lib.
PROCPS_NG_CONF_OPTS += \
	--exec-prefix=$(TOMATOWARE_PREFIX) \
	--libdir=$(TOMATOWARE_PREFIX)/lib

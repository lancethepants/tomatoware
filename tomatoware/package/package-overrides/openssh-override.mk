# openssh.mk spells its configuration, pid and default search paths out.
OPENSSH_CONF_OPTS += \
	--sysconfdir=$(TOMATOWARE_PREFIX)/etc/ssh \
	--with-pid-dir=$(TOMATOWARE_PREFIX)/var/run \
	--with-privsep-path=$(TOMATOWARE_PREFIX)/var/empty \
	--with-default-path=$(TOMATOWARE_PREFIX)/sbin:$(TOMATOWARE_PREFIX)/bin:/usr/sbin:/usr/bin:/sbin:/bin

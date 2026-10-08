# sed.mk spells these out under /usr instead of leaving them to the prefix.
SED_CONF_OPTS += \
	--libexecdir=$(TOMATOWARE_PREFIX)/lib \
	--sysconfdir=$(TOMATOWARE_PREFIX)/etc \
	--datadir=$(TOMATOWARE_PREFIX)/share \
	--mandir=$(TOMATOWARE_PREFIX)/share/man \
	--infodir=$(TOMATOWARE_PREFIX)/share/info

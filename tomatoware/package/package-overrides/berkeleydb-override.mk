# berkeleydb.mk runs configure by hand with /usr and /etc spelled out.
$(eval $(call tomatoware-save,BERKELEYDB_CONFIGURE_CMDS))
define BERKELEYDB_CONFIGURE_CMDS
	$(subst --sysconfdir=/etc,--sysconfdir=$(TOMATOWARE_PREFIX)/etc,\
	$(subst --exec-prefix=/usr,--exec-prefix=$(TOMATOWARE_PREFIX),\
	$(subst --prefix=/usr,--prefix=$(TOMATOWARE_PREFIX),\
	$(BERKELEYDB_CONFIGURE_CMDS_BUILDROOT))))
endef

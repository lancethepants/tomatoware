# libopenssl.mk runs Configure by hand with /usr and /etc/ssl spelled out.
$(eval $(call tomatoware-save,LIBOPENSSL_CONFIGURE_CMDS))
define LIBOPENSSL_CONFIGURE_CMDS
	$(subst --openssldir=/etc/ssl,--openssldir=$(TOMATOWARE_PREFIX)/etc/ssl,\
	$(subst --prefix=/usr,--prefix=$(TOMATOWARE_PREFIX),\
	$(LIBOPENSSL_CONFIGURE_CMDS_BUILDROOT)))
endef

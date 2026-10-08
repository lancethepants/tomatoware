# libcurl.mk points at the certificates in /etc/ssl.
LIBCURL_CONF_OPTS += \
	--with-ca-path=$(TOMATOWARE_PREFIX)/etc/ssl/certs \
	--with-ca-bundle=$(TOMATOWARE_PREFIX)/etc/ssl/certs/ca-certificates.crt

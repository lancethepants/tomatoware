# gnutls.mk points at the certificates in /etc/ssl.
GNUTLS_CONF_OPTS += \
	--with-default-trust-store-file=$(TOMATOWARE_PREFIX)/etc/ssl/certs/ca-certificates.crt

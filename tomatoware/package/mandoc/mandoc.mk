################################################################################
#
# mandoc
#
################################################################################

MANDOC_VERSION = 1.14.6
MANDOC_SITE = https://mandoc.bsd.lv/snapshots
MANDOC_LICENSE = ISC
MANDOC_LICENSE_FILES = LICENSE
MANDOC_DEPENDENCIES = zlib $(if $(BR2_PACKAGE_MUSL_FTS),musl-fts)

# mandoc's configure finds out what the C library has by compiling and then
# running a test program for each feature, which a cross build can't do. A
# value given in configure.local is taken as is, so the answers for musl are
# in configure.local.in.
define MANDOC_CONFIGURE_CMDS
	sed -e 's|@PREFIX@|$(TOMATOWARE_PREFIX)|g' \
		-e 's|@CC@|$(TARGET_CC)|g' \
		-e 's|@AR@|$(TARGET_AR)|g' \
		-e 's|@CFLAGS@|$(TARGET_CFLAGS)|g' \
		-e 's|@LDFLAGS@|$(TARGET_LDFLAGS)|g' \
		-e 's|@LDADD@|$(if $(BR2_PACKAGE_MUSL_FTS),-lfts)|g' \
		$(MANDOC_PKGDIR)/configure.local.in > $(@D)/configure.local
	cd $(@D) && $(TARGET_MAKE_ENV) ./configure
endef

define MANDOC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define MANDOC_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

# The host build exists to run makewhatis over the finished bundle, see
# board/common/post-image.sh.
MANDOC_DEPENDENCIES += host-mandoc
HOST_MANDOC_DEPENDENCIES = host-zlib

define HOST_MANDOC_CONFIGURE_CMDS
	printf '%s\n' \
		'PREFIX="$(HOST_DIR)"' \
		'CC="$(HOSTCC)"' \
		'CFLAGS="$(HOST_CFLAGS) -std=gnu17 -fcommon"' \
		'LDFLAGS="$(HOST_LDFLAGS)"' \
		'STATIC=" "' \
		> $(@D)/configure.local
	cd $(@D) && $(HOST_MAKE_ENV) ./configure
endef

define HOST_MANDOC_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_MANDOC_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))

# With a merged /usr, util-linux.mk pins these to /usr so the install doesn't
# try to move libraries between /lib and /usr/lib.
UTIL_LINUX_CONF_OPTS += \
	--bindir=$(TOMATOWARE_PREFIX)/bin \
	--sbindir=$(TOMATOWARE_PREFIX)/sbin \
	--libdir=$(TOMATOWARE_PREFIX)/lib
UTIL_LINUX_LIBS_CONF_OPTS += \
	--bindir=$(TOMATOWARE_PREFIX)/bin \
	--sbindir=$(TOMATOWARE_PREFIX)/sbin \
	--libdir=$(TOMATOWARE_PREFIX)/lib

# arm-ft: musl defines SYS_statmount and SYS_listmount whatever the kernel
# headers are, so configure enables the statmount API, but its structures and
# constants come from <linux/mount.h>, which Linux 2.6.36 doesn't have.
ifeq ($(BR2_PACKAGE_HOST_LINUX_HEADERS_CUSTOM_REALLY_OLD),y)
UTIL_LINUX_CONF_ENV += \
	ul_cv_syscall_statmount=no \
	ul_cv_syscall_listmount=no
endif

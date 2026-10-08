# libglib2.mk spells the GIO module directory out. meson takes the option
# once, so it is replaced rather than appended.
$(eval LIBGLIB2_CONF_OPTS_BUILDROOT = $(value LIBGLIB2_CONF_OPTS))
LIBGLIB2_CONF_OPTS = $(subst =/usr/lib/gio/modules,=$(TOMATOWARE_PREFIX)/lib/gio/modules,$(LIBGLIB2_CONF_OPTS_BUILDROOT))

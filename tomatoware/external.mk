# Where the bundle lives on the router. Target packages are configured with
# this prefix (see src/patches/0001-configurable-target-install-prefix.patch),
# while the skeleton's "mmc -> usr" symlink keeps Buildroot's own usr/ layout
# on disk. The musl and gcc patches in patches/ carry the same path literally.
TOMATOWARE_PREFIX = /mmc
export TOMATOWARE_PREFIX

TARGET_INSTALL_PREFIX = $(TOMATOWARE_PREFIX)
TARGET_INSTALL_SYSCONFDIR = $(TOMATOWARE_PREFIX)/etc
TARGET_INSTALL_LOCALSTATEDIR = $(TOMATOWARE_PREFIX)/var

# target-finalize strips the target directory of everything a root filesystem
# doesn't need: headers, static libraries, pkg-config and aclocal files, man
# pages, and every *.cmake file. Libraries also install those to staging, but programs
# don't, and some of them can't work without (cmake's modules, gcc's libgcc.a
# and C++ headers, pkg.m4). Finalize hooks run before the deletion, so copy
# them aside here; post-image.sh puts them back.
TOMATOWARE_DEV_DIR = $(BASE_DIR)/tomatoware-dev
export TOMATOWARE_DEV_DIR

define TOMATOWARE_KEEP_DEV_FILES
	mkdir -p $(TOMATOWARE_DEV_DIR)$(TOMATOWARE_PREFIX)
	rsync -a --prune-empty-dirs \
		--include='/include/***' \
		--include='/share/aclocal/***' \
		--include='/lib/pkgconfig/***' \
		--include='/share/pkgconfig/***' \
		--include='/lib/cmake/***' \
		--include='/share/cmake/***' \
		--include='/share/man/***' \
		--include='/man/***' \
		--include='*/' \
		--include='/lib/**.cmake' \
		--include='/share/**.cmake' \
		--include='/lib/**.a' \
		--include='/libexec/**.a' \
		--exclude='*' \
		$(TARGET_DIR)/usr/ $(TOMATOWARE_DEV_DIR)$(TOMATOWARE_PREFIX)/
endef
TARGET_FINALIZE_HOOKS += TOMATOWARE_KEEP_DEV_FILES

# libtool archives record the configured libdir (/mmc/lib), which does not
# exist on the build machine, and Buildroot only knows how to re-root /usr
# and /lib. Nothing needs them, so drop them as soon as they are installed.
define TOMATOWARE_REMOVE_LA
	$(if $(filter end-install-staging,$(1)-$(2)),\
		find $(STAGING_DIR)/usr/lib/ -name '*.la' -delete)
endef
GLOBAL_INSTRUMENTATION_HOOKS += TOMATOWARE_REMOVE_LA

# $(call tomatoware-save,VAR) keeps Buildroot's definition of VAR, unexpanded,
# as VAR_BUILDROOT. An override can then redefine VAR in terms of it, which
# is the only way to change one argument in the middle of a recipe.
define tomatoware-save
define $(1)_BUILDROOT
$(value $(1))
endef
endef

include $(sort $(wildcard $(BR2_EXTERNAL_TOMATOWARE_PATH)/package/*/*.mk))

BUILDROOT_VERSION = 2026.08
BUILDROOT_TARBALL = ${HOME}/buildroot-src/buildroot/buildroot-$(BUILDROOT_VERSION).tar.xz
BUILDROOT_URL = https://github.com/tomato64/buildroot-release/releases/download/$(BUILDROOT_VERSION)

TARGETS = x86_64 arm64 arm arm-ft

# Every target gets its own Buildroot output directory, so the targets can
# coexist and there is no need to distclean when switching between them.
# $(1) = target
BR2 = make -C src/buildroot BR2_EXTERNAL=$(CURDIR)/tomatoware O=$(CURDIR)/output/$(1)

# Build-progress indicator in the terminal title bar (see tomatoware/scripts/progress.sh).
PROGRESS = $(CURDIR)/tomatoware/scripts/progress.sh

# Default target: continue building the last configured target, or x86_64 if none
default:
	@if [ -f .target ]; then \
		$(MAKE) $$(cat .target); \
	else \
		$(MAKE) x86_64; \
	fi

menuconfig:
	@if [ -f .target ]; then \
		$(MAKE) $$(cat .target)-menuconfig; \
	else \
		$(MAKE) x86_64-menuconfig; \
	fi

# The .config is regenerated whenever the defconfig changes, so edit the
# defconfig (or run <target>-savedefconfig) to make a setting stick.
#
# Per-target rules:
#   make <target>               build the bundle
#   make <target>-<anything>    run a Buildroot target in that output directory,
#                               e.g. arm64-menuconfig, x86_64-native-gcc-rebuild
#   make <target>-clean         delete that target's output directory
define TARGET_RULES
$(1): output/$(1)/.config
	@echo $(1) > .target
	@rm -rf output/$(1)/.build-progress
	export BR2_PROGRESS_TOTAL=$$$$($(PROGRESS) --total output/$(1)); \
	$$(call BR2,$(1)) BR2_INSTRUMENTATION_SCRIPTS=$(PROGRESS)

output/$(1)/.config: tomatoware/configs/$(1)_defconfig .patch
	$$(call BR2,$(1)) $(1)_defconfig

$(1)-clean:
	rm -rf output/$(1)

$(1)-%: output/$(1)/.config
	$$(call BR2,$(1)) $$*
endef
$(foreach t,$(TARGETS),$(eval $(call TARGET_RULES,$(t))))

# The defconfigs are sources. Without this, Make would match
# tomatoware/configs/arm-ft_defconfig against the arm-% rule above and try
# to "remake" it in output/arm.
$(foreach t,$(TARGETS),tomatoware/configs/$(t)_defconfig): ;

distclean:
	rm -rf src/buildroot output
	rm -f .patch .extract-buildroot .download-buildroot .target

.patch: .extract-buildroot
	for patch in $(sort $(wildcard src/patches/*.patch)); do \
		patch -p1 -d src/buildroot < $$patch || exit 1; \
	done
	@touch $@

.extract-buildroot: .download-buildroot
	rm -rf src/buildroot src/buildroot-$(BUILDROOT_VERSION)
	tar xJf $(BUILDROOT_TARBALL) -C src/
	mv src/buildroot-$(BUILDROOT_VERSION) src/buildroot
	@touch $@

.download-buildroot:
	mkdir -p ${HOME}/buildroot-src/buildroot
ifeq (,$(wildcard $(BUILDROOT_TARBALL)))
	wget -O $(BUILDROOT_TARBALL) $(BUILDROOT_URL)/buildroot-$(BUILDROOT_VERSION).tar.xz
endif
	@touch $@

.PHONY: default menuconfig distclean $(TARGETS) $(addsuffix -clean,$(TARGETS))

# Anything else is a Buildroot target for the last configured target
.DEFAULT:
	@if [ -f .target ]; then \
		$(call BR2,$$(cat .target)) $@; \
	else \
		echo "No target configured yet. Run one of: $(TARGETS)"; exit 1; \
	fi

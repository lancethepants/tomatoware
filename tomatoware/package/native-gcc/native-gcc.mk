################################################################################
#
# native-gcc
#
################################################################################

# Same version, tarball and patches as the Buildroot cross compiler
# (package/gcc/gcc.mk). This is required, not just convenient: the target
# libraries are built by the cross compiler, so the two must match.
NATIVE_GCC_VERSION = $(GCC_VERSION)
NATIVE_GCC_SITE = $(GCC_SITE)
NATIVE_GCC_SOURCE = $(GCC_SOURCE)
NATIVE_GCC_DL_SUBDIR = gcc
NATIVE_GCC_LICENSE = $(HOST_GCC_LICENSE)
NATIVE_GCC_LICENSE_FILES = $(HOST_GCC_LICENSE_FILES)

NATIVE_GCC_DEPENDENCIES = binutils gmp mpfr mpc zlib zstd

NATIVE_GCC_EXCLUDES = $(HOST_GCC_EXCLUDES)
NATIVE_GCC_POST_PATCH_HOOKS += HOST_GCC_APPLY_PATCHES
NATIVE_GCC_LIBTOOL_PATCH = NO

NATIVE_GCC_SUBDIR = build
NATIVE_GCC_PRE_CONFIGURE_HOOKS += HOST_GCC_CONFIGURE_SYMLINK

# Take the arch/cpu/abi/float selection straight from the cross compiler.
NATIVE_GCC_ARCH_OPTS = $(filter \
	--with-arch=% --with-abi=% --with-cpu=% --with-fpu=% --with-float=% \
	--with-mode=% --with-simd=%,$(HOST_GCC_COMMON_CONF_OPTS))

# --with-build-time-tools: configure probes the assembler and linker, and the
# ones in $(TOMATOWARE_PREFIX) can't run on the build machine.
#
# Plugin support is on by default, so --enable-plugin is deliberately not
# passed: libcc1's configure can't probe for -rdynamic when build != host =
# target (it uses $gcc_cv_objdump, which only gcc/configure sets), and an
# explicit --enable-plugin turns that into a hard error. libcc1 itself is
# only gdb's "compile" backend.
NATIVE_GCC_CONF_OPTS = \
	--with-sysroot=$(TOMATOWARE_PREFIX) \
	--with-build-sysroot=$(STAGING_DIR) \
	--with-build-time-tools=$(HOST_DIR)/$(GNU_TARGET_NAME)/bin \
	--enable-languages=c,c++ \
	--enable-shared \
	--enable-static \
	--enable-threads=posix \
	--enable-tls \
	--enable-__cxa_atexit \
	--enable-default-pie \
	--enable-default-ssp \
	--enable-lto \
	--enable-libgomp \
	--with-gnu-as \
	--with-gnu-ld \
	--with-system-zlib \
	--with-gmp=$(STAGING_DIR)/usr \
	--with-mpfr=$(STAGING_DIR)/usr \
	--with-mpc=$(STAGING_DIR)/usr \
	--with-zstd=$(STAGING_DIR)/usr \
	--without-isl \
	--disable-bootstrap \
	--disable-decimal-float \
	--disable-libcc1 \
	--disable-libsanitizer \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-multilib \
	--disable-werror \
	--with-pkgversion="Tomatoware" \
	$(NATIVE_GCC_ARCH_OPTS)

NATIVE_GCC_CONF_ENV = \
	$(HOST_GCC_COMMON_CONF_ENV) \
	CFLAGS_FOR_TARGET="$(GCC_COMMON_TARGET_CFLAGS)" \
	CXXFLAGS_FOR_TARGET="$(GCC_COMMON_TARGET_CXXFLAGS)" \
	LDFLAGS_FOR_TARGET="$(GCC_COMMON_TARGET_LDFLAGS)"

NATIVE_GCC_MAKE_OPTS = $(HOST_GCC_COMMON_MAKE_OPTS)

define NATIVE_GCC_INSTALL_ALIASES
	ln -sf gcc $(TARGET_DIR)/usr/bin/cc
	$(INSTALL) -m 0755 $(NATIVE_GCC_PKGDIR)/c99 $(TARGET_DIR)/usr/bin/c99
endef
NATIVE_GCC_POST_INSTALL_TARGET_HOOKS += NATIVE_GCC_INSTALL_ALIASES

$(eval $(autotools-package))

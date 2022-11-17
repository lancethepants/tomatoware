# User Configurable Options

# Tomatoware Architecture Choice
export DESTARCH ?= aarch64
#export DESTARCH ?= arm
#export DESTARCH ?= mipsel
#export DESTARCH ?= x86_64

# Arm Target Libc
# Only Supported for Arm
ARM_LIBC ?= uclibc
#ARM_LIBC ?= musl

# Tomatoware Sysroot
# Only /mmc Has Been Test For A Long Time
export PREFIX ?= /mmc
#export PREFIX ?= /mnt

# Build llvm/clang Compiler
# Only Supported For Arm, Aarch64, and x86_64
export BUILDLLVM ?= 1

# Build Mipsel Cross-Toolchain
# Only Supported for Arm + uclibc
export BUILDCROSSTOOLS ?= 1


# Do Not Edit

ifeq ($(DESTARCH), mipsel)
export DESTARCHLIBC = uclibc
export EXTRACFLAGS = -O2 -pipe -mips32 -mtune=mips32
export PATH := $(PATH):/opt/tomatoware/mipsel-$(DESTARCHLIBC)$(subst /,-,$(PREFIX))/bin
endif

ifeq ($(DESTARCH), arm)
export DESTARCHLIBC = $(ARM_LIBC)
export EXTRACFLAGS = -O2 -pipe -march=armv7-a -mtune=cortex-a9
export PATH := $(PATH):/opt/tomatoware/arm-$(DESTARCHLIBC)$(subst /,-,$(PREFIX))/bin
export PATH := $(PATH):/opt/tomatoware/mipsel-uclibc$(subst /,-,$(PREFIX))/bin
endif

ifeq ($(DESTARCH), aarch64)
export DESTARCHLIBC = musl
export EXTRACFLAGS = -mcpu=cortex-a53
export PATH := $(PATH):/opt/tomatoware/aarch64-$(DESTARCHLIBC)$(subst /,-,$(PREFIX))/bin
endif

ifeq ($(DESTARCH), x86_64)
export DESTARCHLIBC = musl
export EXTRACFLAGS =
export PATH := $(PATH):/opt/tomatoware/x86_64-$(DESTARCHLIBC)$(subst /,-,$(PREFIX))/bin
endif

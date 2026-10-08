#!/bin/bash
#
# Assemble the tomatoware bundle.
#
# Neither Buildroot tree is usable on its own: target/ has every program
# (stripped) but no headers or static libraries, staging/ has those but only
# the packages that install libraries. The bundle is target/usr with the
# development files from staging/usr added on top.
#
# $1 = images directory, $2 = target name (BR2_ROOTFS_POST_IMAGE_SCRIPT_ARGS)

set -e

BINARIES_DIR="$1"
TARGET_NAME="$2"
BOARD_DIR="$(dirname "$(readlink -f "$0")")"
PREFIX="${TOMATOWARE_PREFIX:?TOMATOWARE_PREFIX is not set}"
ROOT="${BINARIES_DIR}/root${PREFIX}"
# Tomato64 has GNU tar and busybox xz, so it can unpack xz. FreshTomato's
# busybox tar has no xz support and the firmware has no xz binary, so arm-ft
# ships as gzip.
case "${TARGET_NAME}" in
arm-ft) COMPRESS="gzip -9" EXT=gz ;;
*)      COMPRESS="xz" EXT=xz ;;
esac
TARBALL="${BINARIES_DIR}/tomatoware-${TARGET_NAME}-musl${PREFIX//\//-}.tar.${EXT}"

rm -rf "${BINARIES_DIR}/root"
mkdir -p "${ROOT}"

# -H: git installs well over a hundred hard links to one binary.
rsync -aH "${TARGET_DIR}/usr/" "${ROOT}/"
rsync -aH --ignore-existing --exclude='*.la' "${STAGING_DIR}/usr/" "${ROOT}/"
if [ -d "${TOMATOWARE_DEV_DIR}${PREFIX}" ]; then
	rsync -aH --ignore-existing --exclude='*.la' "${TOMATOWARE_DEV_DIR}${PREFIX}/" "${ROOT}/"
fi

# The native gcc uses ${PREFIX} as its sysroot and looks for headers in
# <sysroot>/usr/include.
ln -sfn . "${ROOT}/usr"

# The skeleton's own symlinks are only needed inside the Buildroot trees,
# and os-release describes a root filesystem, which this is not.
rm -f "${ROOT}/lib32" "${ROOT}/lib64"
rm -f "${ROOT}/etc/os-release" "${ROOT}/lib/os-release"

# Packages that hardcode --prefix=/usr leave it in their .pc file.
find "${ROOT}/lib/pkgconfig" "${ROOT}/share/pkgconfig" -name '*.pc' 2>/dev/null | \
	xargs -r sed -i -E "s#^(prefix|exec_prefix|libdir|includedir)=/usr#\1=${PREFIX}#"

# Buildroot rewrites *-config scripts to point into the staging directory,
# and packages that record how they were built (perl's Config.pm, libtool)
# name the cross tools by their full path. The staging directory lives under
# the host directory, so it has to be handled first.
grep -rIl -- "${HOST_DIR}" "${ROOT}" 2>/dev/null | \
	xargs -r sed -i \
		-e "s#${STAGING_DIR}/usr#${PREFIX}#g" \
		-e "s#${STAGING_DIR}#${PREFIX}#g" \
		-e "s#${HOST_DIR}/bin/#${PREFIX}/bin/#g"

# Point script interpreters at the bundle when the bundle provides them.
# /bin/sh is left alone: the firmware always has one.
find "${ROOT}" -type f -perm -u+x | while read -r f; do
	IFS= read -r line < "$f" 2>/dev/null || continue
	case "$line" in
	'#!'*) ;;
	*) continue ;;
	esac
	interp="$(printf '%s' "$line" | sed -E 's/^#! *([^ ]+).*/\1/')"
	case "$interp" in
	/bin/sh|/usr/bin/env|"${PREFIX}"/*) continue ;;
	/bin/*|/usr/bin/*|/sbin/*|/usr/sbin/*) ;;
	*) continue ;;
	esac
	name="$(basename "$interp")"
	if [ -x "${ROOT}/bin/${name}" ]; then
		sed -i -E "1s#^\#! *${interp}#\#!${PREFIX}/bin/${name}#" "$f"
	fi
done

# gcc installs itself under the target tuple as well, binutils does not.
# Build systems that were told the cross tool names expect both.
tuple="$(basename "$(ls -d "${ROOT}"/lib/gcc/*/)")"
for tool in "${ROOT}/${tuple}"/bin/*; do
	name="$(basename "$tool")"
	[ -e "${ROOT}/bin/${tuple}-${name}" ] || ln -s "${name}" "${ROOT}/bin/${tuple}-${name}"
done

# musl's loader doubles as ldd.
loader="$(basename "$(ls "${ROOT}"/lib/ld-musl-*.so.1)")"
ln -sf "../lib/${loader}" "${ROOT}/bin/ldd"

# Index the man pages. Without an index man still finds a page by searching
# the directories, but complains about it every time, and apropos has nothing
# to search. The index format doesn't depend on the architecture, so the host
# build of mandoc can write it.
if [ -x "${HOST_DIR}/sbin/makewhatis" ]; then
	for mandir in "${ROOT}/share/man" "${ROOT}/man"; do
		if [ -d "${mandir}" ]; then
			"${HOST_DIR}/sbin/makewhatis" "${mandir}"
		fi
	done
fi

# OpenSSL's default CA file is <openssldir>/cert.pem; point it at the bundle
# so programs that only look for a file, not the hashed directory, find it.
if [ -f "${ROOT}/etc/ssl/certs/ca-certificates.crt" ] && [ ! -e "${ROOT}/etc/ssl/cert.pem" ]; then
	ln -s certs/ca-certificates.crt "${ROOT}/etc/ssl/cert.pem"
fi

# musl has no ldconfig, but libtool runs it after installing a library.
[ -e "${ROOT}/bin/ldconfig" ] || ln -s true "${ROOT}/bin/ldconfig"

mkdir -p "${ROOT}/etc" "${ROOT}/share/tomatoware" "${ROOT}/var/cache"
sed "s#@PREFIX@#${PREFIX}#g" "${BOARD_DIR}/profile" > "${ROOT}/etc/profile"
install -m 0755 "${BOARD_DIR}/smoke-test.sh" "${ROOT}/share/tomatoware/smoke-test.sh"
install -m 0755 "${BOARD_DIR}/build-test.sh" "${ROOT}/share/tomatoware/build-test.sh"
echo "tomatoware ${TARGET_NAME} musl ${PREFIX} (buildroot ${BR2_VERSION})" > "${ROOT}/etc/tomatoware-release"
chmod 1777 "${ROOT}/tmp"

"${BOARD_DIR}/verify-elf.sh" "${ROOT}" "${PREFIX}"

# Contents are relative to ${PREFIX}: unpack with "tar xf ... -C ${PREFIX}".
tar -C "${ROOT}" --owner=0 --group=0 --numeric-owner \
	--use-compress-program="${COMPRESS}" -cf "${TARBALL}" .
echo "Created ${TARBALL}"

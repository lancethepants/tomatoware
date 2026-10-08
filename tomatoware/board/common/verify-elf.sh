#!/bin/bash
#
# Check that every executable and shared library in the bundle is
# self-contained: it asks for the bundled loader, has no rpath leaking a
# build directory, and every library it needs ships in the bundle.
#
# $1 = bundle root, $2 = prefix it will be unpacked at

ROOT="$1"
PREFIX="$2"
READELF="$(ls "${HOST_DIR}"/bin/*-readelf 2>/dev/null | head -n1)"
READELF="${READELF:-readelf}"

names="$(mktemp)"
trap 'rm -f "$names"' EXIT
find "${ROOT}" \( -type f -o -type l \) -printf '%f\n' | sort -u > "$names"

errors=0
fail() {
	echo "verify-elf: ${1#"${ROOT}"}: $2" >&2
	errors=$((errors + 1))
}

while read -r f; do
	[ "$(head -c4 "$f" | tr -d '\0')" = $'\x7fELF' ] || continue
	case "$("$READELF" -hW "$f" 2>/dev/null | sed -n 's/^ *Type: *\([A-Z]*\).*/\1/p')" in
	EXEC|DYN) ;;
	*) continue ;;
	esac

	interp="$("$READELF" -lW "$f" 2>/dev/null | sed -n 's/.*Requesting program interpreter: \(.*\)\]/\1/p')"
	case "$interp" in
	""|"${PREFIX}"/lib/ld-musl-*.so.1) ;;
	*) fail "$f" "interpreter is $interp" ;;
	esac

	dyn="$("$READELF" -dW "$f" 2>/dev/null)"

	rpath="$(printf '%s\n' "$dyn" | sed -n 's/.*(R\(UN\)\?PATH).*\[\(.*\)\]/\2/p')"
	case "$rpath" in
	*"${BASE_DIR:-/nonexistent}"*|*/output/*) fail "$f" "rpath leaks build directory: $rpath" ;;
	esac

	printf '%s\n' "$dyn" | sed -n 's/.*(NEEDED).*\[\(.*\)\]/\1/p' | while read -r lib; do
		grep -qxF "$lib" "$names" || echo "$lib"
	done > "$names.missing"
	while read -r lib; do
		fail "$f" "needs $lib, which is not in the bundle"
	done < "$names.missing"
	rm -f "$names.missing"
done < <(find "${ROOT}" -type f ! -name '*.o' ! -name '*.a')

if [ "$errors" -ne 0 ]; then
	echo "verify-elf: $errors problem(s) found" >&2
	exit 1
fi
echo "verify-elf: OK"

#!/bin/sh
#
# Run on the router after unpacking the bundle: compiles and runs a C and a
# C++ program, dynamically and statically, and checks they use our loader.

set -e

PREFIX="$(cd "$(dirname "$0")/../.." && pwd)"
PATH="$PREFIX/bin:$PATH"
dir="$(mktemp -d "$PREFIX/tmp/smoke.XXXXXX")"
trap 'rm -rf "$dir"' EXIT
cd "$dir"

cat > hello.c <<'EOC'
#include <stdio.h>
int main(void) { puts("hello from C"); return 0; }
EOC

cat > hello.cpp <<'EOC'
#include <iostream>
#include <string>
#include <vector>
int main() {
	std::vector<std::string> v{"hello", "from", "C++"};
	for (const auto &s : v) std::cout << s << ' ';
	std::cout << std::endl;
	return 0;
}
EOC

gcc --version | head -n1

gcc -O2 -o hello-c hello.c
./hello-c
g++ -O2 -o hello-cpp hello.cpp
./hello-cpp
gcc -O2 -static -o hello-c-static hello.c
./hello-c-static
g++ -O2 -static -o hello-cpp-static hello.cpp
./hello-cpp-static
gcc -O2 -flto -o hello-c-lto hello.c
./hello-c-lto

interp="$(readelf -lW hello-c | sed -n 's/.*Requesting program interpreter: \(.*\)\]/\1/p')"
case "$interp" in
"$PREFIX"/lib/ld-musl-*.so.1) echo "interpreter: $interp" ;;
*) echo "FAIL: interpreter is $interp" >&2; exit 1 ;;
esac

echo "smoke test passed"

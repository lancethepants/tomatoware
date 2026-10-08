#!/bin/sh
#
# Run on the router after smoke-test.sh passes. Exercises the build tools
# together the way a real project does: autoreconf (autoconf, automake,
# libtoolize, m4, perl), configure, make, a libtool shared library, flex and
# bison, and the archive and text utilities.

set -e

PREFIX="$(cd "$(dirname "$0")/../.." && pwd)"
PATH="$PREFIX/bin:$PREFIX/sbin:$PATH"
export PATH
export M4="$PREFIX/bin/m4"
export CONFIG_SHELL="$PREFIX/bin/bash"
export TMPDIR="$PREFIX/tmp"

dir="$(mktemp -d "$PREFIX/tmp/build.XXXXXX")"
trap 'rm -rf "$dir"' EXIT
cd "$dir"

# Keep every cache the tools would otherwise put in $HOME (pip, ccache when
# meson picks it up, git) inside the scratch directory.
export XDG_CACHE_HOME="$dir/cache"
export CCACHE_DIR="$dir/ccache"
export PIP_CACHE_DIR="$dir/cache/pip"

step() { echo; echo "=== $* ==="; }

step "perl"
perl -MPOSIX -MFile::Spec -MData::Dumper -e 'print "perl $^V, POSIX floor(2.7)=", POSIX::floor(2.7), "\n"'

step "autotools project with a libtool library"
mkdir proj && cd proj
cat > configure.ac <<'EOC'
AC_INIT([twtest], [1.0])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([foreign])
AC_PROG_CC
AC_PROG_CXX
LT_INIT
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
EOC
cat > Makefile.am <<'EOC'
ACLOCAL_AMFLAGS = -I m4
lib_LTLIBRARIES = libtwtest.la
libtwtest_la_SOURCES = twtest.c
bin_PROGRAMS = twhello twhellocxx
twhello_SOURCES = main.c
twhello_LDADD = libtwtest.la
twhellocxx_SOURCES = maincxx.cpp
twhellocxx_LDADD = libtwtest.la
EOC
cat > twtest.c <<'EOC'
int twtest_answer(void) { return 42; }
EOC
cat > main.c <<'EOC'
#include "config.h"
#include <stdio.h>
int twtest_answer(void);
int main(void) { printf("%s: answer %d\n", PACKAGE_STRING, twtest_answer()); return 0; }
EOC
cat > maincxx.cpp <<'EOC'
#include <iostream>
extern "C" int twtest_answer(void);
int main() { std::cout << "c++: answer " << twtest_answer() << std::endl; return 0; }
EOC
mkdir m4
autoreconf -fi
./configure --prefix="$dir/inst"
make -j"$(nproc)"
make install
"$dir/inst/bin/twhello"
"$dir/inst/bin/twhellocxx"
ls "$dir/inst/lib"/libtwtest.so* >/dev/null
ldd "$dir/inst/bin/twhello"
cd "$dir"

step "flex and bison"
cat > calc.y <<'EOC'
%{
#include <stdio.h>
int yylex(void);
void yyerror(const char *s) { fprintf(stderr, "%s\n", s); }
%}
%token NUM
%left '+'
%%
line: expr '\n' { printf("sum %d\n", $1); } ;
expr: NUM | expr '+' expr { $$ = $1 + $3; } ;
%%
int main(void) { return yyparse(); }
EOC
cat > calc.l <<'EOC'
%{
#include <stdlib.h>
#include "calc.tab.h"
%}
%option noyywrap nounput noinput
%%
[0-9]+  { yylval = atoi(yytext); return NUM; }
[+\n]   { return yytext[0]; }
[ \t]   ;
%%
EOC
bison -d calc.y
flex calc.l
gcc -O2 -o calc calc.tab.c lex.yy.c
[ "$(echo '40 + 2' | ./calc)" = "sum 42" ]
echo "calc: 40 + 2 = 42"

step "archive and text tools"
mkdir data
seq 1 20000 > data/numbers
cp calc.y data/
for c in gzip bzip2 xz zstd; do
	tar -cf - data | $c -c > data.tar.$c
	mkdir out.$c
	$c -dc data.tar.$c | tar -xf - -C out.$c
	diff -r data out.$c/data
	echo "tar + $c: ok"
done
sed 's/^1$/one/' data/numbers > numbers.new
diff -u data/numbers numbers.new > numbers.patch || true
patch -s -p0 -o numbers.patched data/numbers < numbers.patch
cmp numbers.new numbers.patched
echo "diff + patch: ok"
[ "$(gawk '{ s += $1 } END { print s }' data/numbers)" = "200010000" ]
echo "gawk: ok"
[ "$(find data -type f | grep -c .)" = "2" ]
echo "find + grep: ok"
file "$dir/inst/bin/twhello"
pkg-config --version >/dev/null
echo "pkg-config: ok"

step "cmake + ninja, meson + ninja"
mkdir cm && cd cm
cat > CMakeLists.txt <<'EOC'
cmake_minimum_required(VERSION 3.20)
project(twcmake C CXX)
add_executable(twcmake main.c)
EOC
cat > main.c <<'EOC'
#include <stdio.h>
int main(void) { puts("cmake: ok"); return 0; }
EOC
cmake -G Ninja -B build . >/dev/null
ninja -C build >/dev/null
./build/twcmake
cat > meson.build <<'EOC'
project('twmeson', 'c')
executable('twmeson', 'main.c')
EOC
meson setup mbuild >/dev/null
ninja -C mbuild >/dev/null
./mbuild/twmeson | sed 's/cmake/meson/'
cd "$dir"

step "ccache"
ccache gcc -O2 -c cm/main.c -o cc1.o
ccache gcc -O2 -c cm/main.c -o cc2.o
ccache -s | grep -E 'Hits|Misses' | head -n 3

step "python"
python3 - <<'EOC'
import sys, ssl, sqlite3, ctypes, zlib, bz2, lzma, readline, curses, decimal, xml.parsers.expat, hashlib
print("python", sys.version.split()[0], "prefix", sys.prefix)
print("openssl via python:", ssl.OPENSSL_VERSION)
print("default CA file:", ssl.get_default_verify_paths().cafile)
db = sqlite3.connect(":memory:"); print("sqlite", db.execute("select sqlite_version()").fetchone()[0])
print("libc via ctypes: getpid =", ctypes.CDLL(None).getpid())
EOC

step "python C extension, compiled here"
mkdir pyext && cd pyext
cat > twext.c <<'EOC'
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <zlib.h>
static PyObject *answer(PyObject *self, PyObject *args) {
	long a, b;
	if (!PyArg_ParseTuple(args, "ll", &a, &b)) return NULL;
	return PyLong_FromLong(a * b);
}
static PyObject *zver(PyObject *self, PyObject *noargs) { return PyUnicode_FromString(zlibVersion()); }
static PyMethodDef methods[] = {
	{"answer", answer, METH_VARARGS, "multiply"},
	{"zver", zver, METH_NOARGS, "zlib version"},
	{NULL, NULL, 0, NULL}
};
static struct PyModuleDef mod = { PyModuleDef_HEAD_INIT, "twext", NULL, -1, methods };
PyMODINIT_FUNC PyInit_twext(void) { return PyModule_Create(&mod); }
EOC
gcc $(python3-config --cflags) -fPIC -c twext.c -o twext.o
gcc -shared twext.o -lz -o "twext$(python3-config --extension-suffix)"
python3 -c 'import twext; print("extension:", twext.answer(6, 7), "zlib", twext.zver())'
pip --version | cut -d" " -f1-4
python3 -c 'import setuptools; print("setuptools", setuptools.__version__)'
python3 -m venv venv
./venv/bin/python -m pip --version | cut -d" " -f1-2 | sed 's/^/venv: /'
cd "$dir"

step "git"
mkdir repo && cd repo
git init -q .
git -c user.name=tw -c user.email=tw@example.com commit -q --allow-empty -m "test"
git log --oneline | head -n 1
cd "$dir"

step "tls: openssl, curl, wget"
openssl version -a | grep -E '^OpenSSL|OPENSSLDIR'
ls "$PREFIX/etc/ssl/certs/ca-certificates.crt" >/dev/null
echo "CA bundle: present"
if curl -sS -m 20 -o /dev/null -w 'curl https: HTTP %{http_code}\n' https://www.kernel.org/; then
	wget -q -T 20 -O /dev/null https://www.kernel.org/ && echo "wget https: ok"
else
	echo "curl https failed (no network on this router?) - not counted as a failure"
fi

step "other tools start"
gdb --version | head -n 1
gdb -q -batch -ex run -ex bt "$dir/inst/bin/twhello" | tail -n 3
strace -V | head -n 1
vim --version | head -n 1
nano --version | head -n 1
tmux -V
screen --version || true
zsh --version
htop --version | head -n 1
less --version | head -n 1
ssh -V
rsync --version | head -n 1
unzip -v | head -n 1
lz4 --version
cpio --version | head -n 1
which gcc

step "libraries: boost, glib, zlib + openssl static"
cat > lib.cpp <<'EOC'
#include <boost/filesystem.hpp>
#include <boost/regex.hpp>
#include <iostream>
int main() {
	boost::regex re("(\\w+)-(\\d+)");
	boost::smatch m;
	std::string s = "boost-42";
	std::cout << "boost: " << boost::filesystem::path("/a/b.txt").extension().string()
	          << " " << (boost::regex_match(s, m, re) ? m[2].str() : "no match") << std::endl;
	return 0;
}
EOC
g++ -O2 -o lib-dyn lib.cpp -lboost_filesystem -lboost_regex
./lib-dyn
g++ -O2 -static -o lib-static lib.cpp -lboost_filesystem -lboost_regex
./lib-static
cat > glib.c <<'EOC'
#include <glib.h>
int main(void) { g_print("glib %d.%d: %s\n", glib_major_version, glib_minor_version, g_get_prgname() ? "ok" : "ok"); return 0; }
EOC
gcc -O2 -o glib-dyn glib.c $(pkg-config --cflags --libs glib-2.0)
./glib-dyn
cat > st.c <<'EOC'
#include <zlib.h>
#include <openssl/crypto.h>
#include <stdio.h>
int main(void) { printf("static: zlib %s, %s\n", zlibVersion(), OpenSSL_version(0)); return 0; }
EOC
gcc -O2 -static -o st st.c $(pkg-config --static --libs zlib libcrypto)
./st

step "scripting and misc tools"
echo 'print("lua " .. _VERSION .. ", path root " .. package.path:match("^[^;]*"))' | lua -
echo 'puts "tcl [info patchlevel]"' | tclsh
[ "$(TZ=Asia/Tokyo date +%Z)" = "JST" ]
echo "zoneinfo: Asia/Tokyo -> JST"
gpg --version | head -n 1
gnutls-cli --version | head -n 1
(7za --help 2>/dev/null || 7zr --help) | sed -n 2p
unrar | sed -n 2p
ps --version
lsblk --version

step "mold, upx, distcc, slibtool, man"
# Separate commands, not "&&" chains: set -e ignores a failure on the left
# of "&&", so a failed link would go unnoticed.
gcc -O2 -fuse-ld=mold -o hello-mold cm/main.c
./hello-mold | sed 's/cmake/mold link/'
readelf -p .comment hello-mold | grep -o 'mold [0-9.]*' | head -n 1
cp hello-mold hello-upx
upx -q hello-upx >/dev/null
./hello-upx | sed 's/cmake/upx packed/'
distcc --version | head -n 1
slibtool --version | head -n 1
man -w gcc
man gcc | head -n 6 | tail -n 3

echo
echo "build test passed"

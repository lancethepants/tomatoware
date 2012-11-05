tomatoware
==========

Tomatoware is a set of helpful scripts to compile additional software for tomato firmware.

The following packages should be sufficient to compile this software.

sudo apt-get install libncurses5 libncurses5-dev m4 bison flex libstdc++6-4.4-dev g++-4.4 g++ libtool sqlite

sudo apt-get install gcc g++ binutils patch bzip2 flex bison make gettext unzip zlib1g-dev

sudo apt-get install libc6 libncurses5-dev  automake automake1.7 automake1.9

sudo apt-get install git-core

install.sh will download the necessary toolchain and software packages and will compile it with the /opt prefix.  This is designed to run in /opt, much like optware for embedded devices.

package.sh will compress everything into opt.tgz, which can then be transferred to /opt in the target device to be extracted.

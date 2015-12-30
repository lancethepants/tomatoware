tomatoware
==========

Tomatoware is a development environment for mipsel and ARM embedded routers. It can be used to compile userland applications natively on these devices.

Downloads for the project can be found on the github project releases page. https://github.com/lancethepants/tomatoware/releases

Downloads for the project can also be found at http://lancethepants.com/files

Compiling
==========

Tomatoware can be compiled for different root prefixes. It can be mounted to /mmc, /jffs, or any other prefix available on the target system. This allows tomatoware to co-exist with entware/optware, which reside in /opt. 

Edit config.mk to set the desired architecture and prefix, and then run make. It will compile the toolchain if it has not already been done previously, and then it will compile tomatoware.  It must create a separate toolchain for each unique prefix used.

I'm compiling this on a Debian 7 system. I've also sucessfully built Tomatoware on Ubuntu 14.04. The following packages should be sufficient to compile Tomatoware.

sudo apt-get -y install autoconf automake automake1.9 bash binutils bison build-essential bzip2 cmake cvs diffutils doxygen dpkg-dev fakeroot file flex g++ g++-4.4 gawk gcc gcc-multilib gettext git-core gperf groff-base intltool libbz2-dev libc6-dev libcurl4-openssl-dev libgc-dev libglib2.0-dev libslang2 libtool make patch perl pkg-config python python-all python-dev python2.7-dev lib32z1 lib32z-dev libc6 libexpat1-dev libffi-dev libgdbm-dev libncurses-dev libreadline6-dev libssl-dev libsqlite3-dev libstdc++6-4.4-dev libxml-parser-perl m4 sed shtool sqlite subversion tar texinfo tk-dev zlib1g zlib1g-dev unzip libxml2-dev

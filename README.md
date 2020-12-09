tomatoware
==========

Tomatoware is a development environment for mipsel and ARM embedded routers. It can be used to natively compile user space applications for these devices.

Downloads for the project available at:

https://github.com/lancethepants/tomatoware/releases

Nigtly builds also found at:

http://lancethepants.com/files

Compiling
==========

Tomatoware can be compiled with different root prefixes. This allows it to co-exist with entware(-ng)/optware(-ng), which reside in /opt. The official project prefix is /mmc.

Edit `config.mk` to set the desired architecture and prefix and run `make`.

Debian 10 is used to build this project. An included Dockerfile can be used to create a working enviornment. Otherwise the following packages should be sufficient.

apt-get install automake bc bison build-essential cmake cpio curl docbook-xsl flex gawk gettext git libexpat1-dev libffi-dev libglib2.0-dev libncurses5-dev libtool libxml2-dev locales pkg-config po4a python-dev rsync sudo swig texinfo unzip vim wget xsltproc

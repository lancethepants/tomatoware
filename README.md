tomatoware
==========

Tomatoware is a project that creates a native development environment for Tomato firmware supported routers.  
In fact, tomatoware is firmware agnostic, and should work with dd-wrt and other mipsel based firmwares.

Downloads for the project can be found on the github project releases page. https://github.com/lancethepants/tomatoware/releases

Downloads for the project can also be found at http://lancethepants.com/files

This project is called tomatoware because it originally began using the TomatoUSB toolchain, and was designed to use the libraries already found in TomatoUSB firmware.

It soon became apparent that the TomatoUSB toolchain is somewhat antiquated, and insufficient for the purpose of this project.
The decision was made to use a more up-to-date toolchain provided from the entware project. http://code.google.com/p/wl500g-repo/

This project allows you to compile applications natively on your mipsel device.
I wanted this to mimic the 'buildroot' package available from optware.
I really like the idea of freeing users to compile code on their own, instead of being solely dependent on package managers.

Compiling
==========

Running 'make' will compile the toolchain if it is not already installed, and then will compile tomatoware.

Tomatoware now has the ability to be compiled for a different root prefix. This allows you to mount it to /mmc, /jffs, or any other desired location. This also allow tomatoware to co-exist and run along side with entware without conflicting.  By default tomatoware will compile with the /opt prefix.  To change it, run 'make PREFIX=/prefix' with the desired prefix.

Currently I'm compiling this on a Debian 7 system. The following packages should be sufficient to compile Tomatoware.

sudo apt-get -y install autoconf automake automake1.9 bash binutils bison build-essential bzip2 cvs diffutils doxygen dpkg-dev file flex g++ g++-4.4 gawk gcc gcc-multilib gettext git-core gperf groff-base intltool libbz2-dev libc6-dev libcurl4-openssl-dev libgc-dev libglib2.0-dev libslang2 libtool make patch perl pkg-config python python-all python-dev python2.7-dev lib32z1 lib32z-dev libc6 libexpat1-dev libffi-dev libgdbm-dev libncurses-dev  libreadline6-dev libssl-dev libsqlite3-dev libstdc++6-4.4-dev libxml-parser-perl m4 sed shtool sqlite subversion tar texinfo tk-dev zlib1g zlib1g-dev unzip libxml2-dev

Donation
==========

For those of you who have found my project, and are willing to appreciate my many hours of work (and also fulfilled requests), feel free to donate with some coins.

* Bitcoin: `14GENUi5JSGaKzfU9VdfYjaFKWbomTBatW`
* Litecoin: `LKgcmvnLQX7sCc3CUVxBwnf3d1hdfVVu8o`
* Feathercoin: `6pzJ1SfRijHqNs947q6aj7BNHAqQXaSA7V`
* Dogecoin: `DHdXAeg8Lrw4abL5GRquDgoiKp37xWmeRB`

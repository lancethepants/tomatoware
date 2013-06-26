tomatoware
==========

Tomatoware is a set of scripts to create a native compiling environment for tomato firmware supported routers.  
In fact, tomatoware is firmware agnostic, and should work with DD-WRT and other mipsel based firmwares.

Downloads for the project can be found at http://lancethepants.com/files

This project is calld tomatoware because it originally started with the TomatoUSB toolchain, and was designed to use the libraries already built into the TomatoUSB firmware.
I soon found that the TomatoUSB toolchain is somewhat antiquated, and insufficent for the purpose of this project.
I decided to use the more up-to-date toolchain provided from entware. http://code.google.com/p/wl500g-repo/

This project compiles the necessary packages to allow you to compile applications natively on your mipsel device.
I wanted this to mimic the 'buildroot' package available from optware.
I really like the idea of freeing users to compile code on their own, instead of being soley dependant on package managers.

This repo should also be helpful for those wishing to cross-compile their own applications.  
You should be able to follow the model in the scripts, and mimic it for other applications.
I've added a few extra packages to install.sh for myself, mostly for Usenet usage.
Some applications are more fussy than others when cross-compiling, google is your friend.

To be safe, I'm going to say that this is NOT compatible with entware. 
While is uses the same toolchain, many of the libraries are newer.
There are many situations also where they would possibly clash.
This would be a nice feature to see in entware, and maybe one day it could be added. 

I've split things up into 4 different scripts.
You need to cd into tomatoware, and run them all in succession.
./toolchain.sh
./install.sh
./buildroot.sh
./package.sh

I've also added a script called do-all.sh  Make sure your toolchain is already installed, then run do-all.sh and it will run everything through and keep track of the compile time. 

toolchain.sh downloads and installs the entware toolchain in /opt.  This pre-compiled toolchain is compatible with Ubuntu distros. The pre-compiled toolchain does not work with debian systems becuase it requires newer libraries than what debian comes with.  If you are running debian, you instead can compile the toolchain on your own from entware.  Follow entware's compiling instructions, but instead run 'make toolchain', to only build and install the toolchain.

install.sh compiles some pre-requisite libraries and programs, and sets things up for buildroot.sh  

buildroot.sh continues where install.sh left off, and compiled the actual programs needed for the native compiling environment.

package.sh adds the entware libraries and will compress everything into opt.tgz, which can then be transferred to /opt in the target device to be extracted.

Currently I'm compiling this on Ubuntu Server 12.04 and 12.10. I've recently moved to a Debian 7 system, and just have compiled my own entware toolchain as noted above
The following packages should be sufficient to compile this software.  These are probably more than necessary, but libraries I've needed anyway. Some of these are invalid for debian systems, just remove those packages and it should work just fine.

sudo apt-get -y install autoconf automake automake1.7 automake1.9 bash binutils bison build-essential bzip2 cvs diffutils doxygen dpkg-dev file flex g++ g++-4.4 gawk gcc gcc-multilib gettext git-core gperf groff-base intltool libbz2-dev libc6:i386 libc6-dev libcurl4-openssl-dev libgc-dev libglib2.0-dev libslang2 libtool make patch perl pkg-config python python-all python-dev python2.7-dev lib32z1 lib32z-dev libc6 libexpat1-dev libffi-dev libgdbm-dev libncurses-dev  libreadline6-dev libssl-dev libsqlite3-dev libstdc++6-4.4-dev libxml-parser-perl m4 sed shtool sqlite subversion tar texinfo tk-dev zlib1g zlib1g-dev unzip

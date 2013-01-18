tomatoware
==========

Tomatoware is a set of scripts to create a native compiling environment for tomato firmware supported routers.  
In fact, tomatoware is firmware agnostic, and should work with DD-WRT and other mipsel based firmwares.

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

I've split things up into 3 different scripts.  This will likely change at some point in the future.
You need to cd into tomatoware, and run them all in succession.
./install.sh
./buildroot.sh
./package.sh

install.sh downloads the toolchain and deals mostly with the compiling the prerequisite libraries and programs, and sets things up for buildroot.sh  

buildroot.sh continues where install.sh left off, and compiled the actual programs needed for the native compiling environment.

package.sh adds the entware libraries and will compress everything into opt.tgz, which can then be transferred to /opt in the target device to be extracted.

Currently I'm compiling this on Ubuntu Server 12.04 and 12.10.
The following packages should be sufficient to compile this software.

sudo apt-get install autoconf automake automake1.7 automake1.9 bash binutils bison bzip2 cvs diffutils dpkg-dev file flex g++ g++-4.4 gawk gcc gcc-multilib gettext git-core gperf groff-base intltool libbz2-dev libc6:i386 libcurl4-openssl-dev libgc-dev libglib2.0-dev libslang2 libtool make patch perl pkg-config python python-dev lib32z1 libc6 libexpat1-dev libffi-dev libncurses5 libncurses5-dev libreadline6-dev libssl-dev libstdc++6-4.4-dev libxml-parser-perl m4 sed shtool sqlite subversion tar texinfo zlib1g zlib1g-dev unzip

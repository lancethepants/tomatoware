tomatoware
==========

Tomatoware is a set of scripts to create a native compiling environment for tomato firmware supported routers.  
In fact, tomatoware is firmware agnostic, and should work with DD-WRT and other mipsel based firmwares.

This project is calld tomatoware because it originally started with the TomatoUSB toolchain, and was designed to use the libraries already built into the TomatoUSB firmware.
I soon found that the TomatoUSB toolchain is somewhat antiquated, and insufficent for the purposed of this project.
I decided to use the more up-to-date toolchain provided from entware. http://code.google.com/p/wl500g-repo/

This project compiles the packages necessary to allow you to compile applications natively on your mipsel device.
I wanted this to mimic the 'buildroot' package available from optware.
I really like the idea of freeing users to compile code on their own, instead of being soley dependant on package managers.

This repo should also be helpful for those wishing to cross-compile their own applications.  
I've added a few extra packages to install.sh for myself, mostly for Usenet usage.
You should be able to follow the model in the scripts, and mimic it for other applications.
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

Currently I'm compiling this on Ubuntu Server 12.04
The following packages should be sufficient to compile this software.

sudo apt-get install libncurses5 libncurses5-dev m4 bison flex libstdc++6-4.4-dev g++-4.4 g++ libtool sqlite

sudo apt-get install gcc g++ binutils patch bzip2 flex bison make gettext unzip zlib1g-dev

sudo apt-get install libc6 libncurses5-dev  automake automake1.7 automake1.9

sudo apt-get install git-core


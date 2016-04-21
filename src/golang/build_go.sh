#!/bin/sh

PREFIX=/mmc

set -e
set -x

mkdir -p $PREFIX/bin/go/bootstrap && cd $PREFIX/bin/go/bootstrap
wget https://storage.googleapis.com/golang/go1.4.3.src.tar.gz
tar zxvf go1.4.3.src.tar.gz
mv go go1.4 && cd ./go1.4/src
./make.bash
cd $PREFIX/bin/go
wget https://storage.googleapis.com/golang/go1.6.2.src.tar.gz
tar zxvf go1.6.2.src.tar.gz -C $PREFIX/bin
cd $PREFIX/bin/go/src
wget -O $PREFIX/ssl/certs/ca-certificates.crt https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt
sed -i 's,\/etc\/ssl\/certs\/ca-certificates.crt,'"$PREFIX"'\/ssl\/certs\/ca-certificates.crt,g' \
./crypto/x509/root_linux.go
GOROOT_BOOTSTRAP=$PREFIX/bin/go/bootstrap/go1.4 ./make.bash
echo "Go has been installed."

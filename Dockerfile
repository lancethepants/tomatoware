FROM	debian:jessie

RUN	apt-get update && \
	apt-get install -y \
	automake \
	bc \
	bison \
	build-essential \
	cmake \
	cpio \
	curl \
	flex \
	gettext \
	git \
	libexpat1-dev \
	libffi-dev \
	libglib2.0-dev \
	libncurses5-dev \
	libtool \
	libxml2-dev \
	locales \
	pkg-config \
	python \
	sudo \
	texinfo \
	unzip \
	vim \
	wget

RUN	dpkg-reconfigure locales && \
	locale-gen C.UTF-8 && \
	/usr/sbin/update-locale LANG=C.UTF-8

RUN	echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
	locale-gen

ENV	LC_ALL C.UTF-8
ENV	LANG en_US.UTF-8
ENV	LANGUAGE en_US.UTF-8

RUN	mkdir -p /opt/tomatoware && \
	chmod 777 /opt/tomatoware

RUN	useradd -ms /bin/bash tomato && \
	echo "tomato:tomato" | chpasswd && \
	adduser tomato sudo

USER	tomato
WORKDIR	/home/tomato

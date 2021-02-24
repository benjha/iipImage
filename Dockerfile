FROM ubuntu:bionic

### update
RUN apt-get -q update
RUN apt-get -q -y upgrade
RUN apt-get -q -y dist-upgrade
RUN apt-get clean
RUN apt-get -q update

RUN apt-get -q -y install  openssh-server git autoconf automake make libtool pkg-config cmake apache2 libapache2-mod-fcgid libfcgi0ldbl zlib1g-dev libpng-dev libjpeg-dev libtiff5-dev libgdk-pixbuf2.0-dev libxml2-dev libsqlite3-dev libcairo2-dev libglib2.0-dev g++ libmemcached-dev libjpeg-turbo8-dev vim


RUN a2enmod rewrite
RUN a2enmod fcgid

# Slate deployment -->
#RUN mkdir /root/src
#COPY . /root/src
#WORKDIR /root/src
RUN mkdir /src
COPY . /src
WORKDIR /src
# <-- Slate deployment

## replace apache's default fcgi config with ours.
RUN rm /etc/apache2/mods-enabled/fcgid.conf
COPY ./fcgid.conf /etc/apache2/mods-enabled/fcgid.conf

## enable proxy
RUN ln -s /etc/apache2/mods-available/proxy_http.load /etc/apache2/mods-enabled/proxy_http.load
RUN ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/proxy.load
RUN ln -s /etc/apache2/mods-available/proxy.conf /etc/apache2/mods-enabled/proxy.conf

## Add configuration file
COPY apache2.conf /etc/apache2/apache2.conf
COPY ports.conf /etc/apache2/ports.conf

# Slate deployment -->
#WORKDIR /root/src
WORKDIR /src
# <-- Slate deployment

### openjpeg version in ubuntu 14.04 is 1.3, too old and does not have openslide required chroma subsampled images support.  download 2.1.0 from source and build
RUN git clone https://github.com/uclouvain/openjpeg.git --branch=v2.3.0
# Slate deployment -->
#RUN mkdir /root/src/openjpeg/build
#WORKDIR /root/src/openjpeg/build
RUN mkdir /src/openjpeg/build
WORKDIR /src/openjpeg/build
# <-- Slate deployment
RUN cmake -DBUILD_JPIP=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_CODEC=ON -DBUILD_PKGCONFIG_FILES=ON ../
RUN make
RUN make install

### Openslide
# Slate deployment -->
#WORKDIR /root/src
WORKDIR /src
# <-- Slate deployment
## get my fork from openslide source cdoe
RUN git clone https://github.com/openslide/openslide.git

## build openslide
# Slate deployment -->
#WORKDIR /root/src/openslide
WORKDIR /src/openslide
# <-- Slate deployment

RUN git checkout tags/v3.4.1
RUN autoreconf -i
#RUN ./configure --enable-static --enable-shared=no
# may need to set OPENJPEG_CFLAGS='-I/usr/local/include' and OPENJPEG_LIBS='-L/usr/local/lib -lopenjp2'
# and the corresponding TIFF flags and libs to where bigtiff lib is installed.
RUN ./configure
RUN make
RUN make install

###  iipsrv
# Slate deployment -->
#WORKDIR /root/src/iipsrv
WORKDIR /src/iipsrv
# <-- Slate deployment

RUN ./autogen.sh
#RUN ./configure --enable-static --enable-shared=no
RUN ./configure
RUN make
## create a directory for iipsrv's fcgi binary
# Slate deployment -->
#RUN mkdir -p /var/www/localhost/fcgi-bin/
#RUN cp /root/src/iipsrv/src/iipsrv.fcgi /var/www/localhost/fcgi-bin/
RUN mkdir -p /gpfs/alpine/proj-shared/gen150/caMicroscope/apache2/fcgi-bin
RUN cp /src/iipsrv/src/iipsrv.fcgi /gpfs/alpine/proj-shared/gen150/caMicroscope/apache2/fcgi-bin
# <-- Slate deployment


#COPY apache2-iipsrv-fcgid.conf /root/src/iip-openslide-docker/apache2-iipsrv-fcgid.conf

# Slate Deployment -->
#RUN chgrp -R 0 /src && \
#    chmod -R g+rwX /src
#RUN chgrp -R 0 /var && \
#    chmod -R g+rwX /var
#RUN chgrp -R 0 /run && \
#    chmod -R g+rwX /run
#RUN chgrp -R 0 /etc/apache2 && \
#    chmod -R g+rwX /etc/apache2
# 
# USER 1001
RUN sed -i 's#/var/run#/gpfs/alpine/proj-shared/gen150/caMicroscope#g' /etc/apache2/envvars
RUN sed -i 's#/var/lock#/gpfs/alpine/proj-shared/gen150/caMicroscope#g' /etc/apache2/envvars
RUN sed -i 's#/var/log#/gpfs/alpine/proj-shared/gen150/caMicroscope#g' /etc/apache2/envvars 
RUN sed -i 's#/var/log#/gpfs/alpine/proj-shared/gen150/caMicroscope#g' /etc/logrotate.d/apache2
RUN sed -i 's/create 640 root adm/create 644 root adm/g' /etc/logrotate.d/apache2
# <--- Slate Deployment

# CMD service apache2 start && while true; do sleep 1000; done
# CMD apachectl -D FOREGROUND

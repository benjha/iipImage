FROM apachetestslate:latest

#configuring apache webserver
COPY apache2.conf /etc/apache2/apache2.conf
COPY ports.conf /etc/apache2/ports.conf
COPY fcgid.conf /etc/apache2/mods-enabled/fcgid.conf


ENV SOURCE=/code
RUN mkdir ${SOURCE}
COPY . ${SOURCE}
RUN mkdir images
COPY /images /images
WORKDIR ${SOURCE}

# openjpeg version in ubuntu 14.04 is 1.3, too old and does not have openslide required chroma subsampled images support.  
# download 2.1.0 from source and build
RUN git clone https://github.com/uclouvain/openjpeg.git --branch=v2.3.0
RUN mkdir ${SOURCE}/openjpeg/build
WORKDIR ${SOURCE}/openjpeg/build
RUN cmake -DBUILD_JPIP=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_CODEC=ON -DBUILD_PKGCONFIG_FILES=ON ../
RUN make
RUN make install

### Openslide
WORKDIR ${SOURCE}
## get my fork from openslide source cdoe
RUN git clone https://github.com/openslide/openslide.git

## build openslide
WORKDIR ${SOURCE}/openslide
RUN git checkout tags/v3.4.1
RUN autoreconf -i
RUN ./configure --enable-static --enable-shared=no
# may need to set OPENJPEG_CFLAGS='-I/usr/local/include' and OPENJPEG_LIBS='-L/usr/local/lib -lopenjp2'
# and the corresponding TIFF flags and libs to where bigtiff lib is installed.
RUN ./configure
RUN make
RUN make install

###  iipsrv
WORKDIR ${SOURCE}/iipsrv
RUN ./autogen.sh
RUN ./configure
RUN make
RUN cp ${SOURCE}/iipsrv/src/iipsrv.fcgi /fcgid-bin

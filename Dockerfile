FROM apachetestslate:latest

RUN mkdir /code
WORKDIR /code

# openjpeg version in ubuntu 14.04 is 1.3, too old and does not have openslide required chroma subsampled images support.  
# download 2.1.0 from source and build
RUN git clone https://github.com/uclouvain/openjpeg.git --branch=v2.3.0
RUN mkdir /code/openjpeg/build
WORKDIR /src/openjpeg/build
RUN cmake -DBUILD_JPIP=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_CODEC=ON -DBUILD_PKGCONFIG_FILES=ON ../
RUN make
RUN make install

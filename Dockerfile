#   Copyright 2017 Yoshi Yamaguchi
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#   
#   http://www.apache.org/licenses/LICENSE-2.0
#   
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
FROM alpine:3.5
MAINTAINER Yoshi Yamaguchi ymotongpoo@gmail.com

LABEL version="0.5"

ARG BLAS_VERSION=3.6.0
ARG LAPACK_VERSION=3.6.1
ARG USERNAME=jupyter
ENV JUPYTER_WORKDIR=jupyter
ENV JUPYTER_NOTEBOOK_PORT=8888


# install required apk packages
RUN apk update && apk upgrade
RUN apk add \
      python3 \
      python3-dev \
      libpng \
      tiff \
      jpeg \
      libwebp \
      openjpeg \
      freetype \
      zeromq 
RUN apk add --virtual=blas_lapack_deps \
      build-base \
      pkgconfig \
      abuild \
      squashfs-tools \
      libstdc++ \
      libgfortran \
      gfortran \
      ca-certificates
RUN apk add --virtual=other_deps \
      freetype-dev \
      libpng-dev \
      libwebp-dev \
      openjpeg-dev \
      zeromq-dev \
      tiff-dev \
      jpeg-dev \
      lcms2-dev \
      zlib-dev

# build BLAS
RUN mkdir -p /tmp/blas
WORKDIR /tmp/blas
RUN wget http://www.netlib.org/blas/blas-${BLAS_VERSION}.tgz
RUN tar xzf blas-${BLAS_VERSION}.tgz
WORKDIR /tmp/blas/BLAS-${BLAS_VERSION}
RUN gfortran -O3 -m64 -fno-second-underscore -fPIC -c *.f \
    && ar r libfblas.a *.o \
    && ranlib libfblas.a \
    && cp libfblas.a /tmp
RUN gfortran -O3 -m64 -fno-second-underscore -shared -fPIC *.f -o libfblas.so \
    && cp libfblas.so /tmp

# build LAPACK
RUN mkdir -p /tmp/lapack
WORKDIR /tmp/lapack
RUN wget http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz
RUN tar xzf lapack-${LAPACK_VERSION}.tgz
WORKDIR /tmp/lapack/lapack-${LAPACK_VERSION}
RUN sed -e "s/frecursive/fPIC/g" -e "s/ \.\.\// /g" -e "s/^CBLASLIB/\#CBLASLIB/g" make.inc.example > make.inc
RUN make lapacklib \
    && make clean \
    && mv liblapack.a /tmp
RUN mv /tmp/libfblas.a /tmp/libfblas.so /tmp/liblapack.a /usr/local/lib

# for scipy
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h # to build scipy

# set normal user
RUN adduser -s /bin/bash -D -h /home/${USERNAME} ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN python3 -m venv ${JUPYTER_WORKDIR}
WORKDIR /home/${USERNAME}/${JUPYTER_WORKDIR}
USER root
ADD requirements.txt .
RUN chown ${USERNAME} requirements.txt
USER ${USERNAME}
RUN . bin/activate \
    && export BLAS=/usr/local/lib/libfblas.so \
    && export LAPACK=/urs/local/lib/liblapack.a \
    && pip3 install --no-cache-dir --upgrade pip \
    && CFLAGS="$CFLAGS -L/lib" pip3 install --no-cache-dir -r requirements.txt

USER root
RUN apk del --purge -r blas_lapack_deps
RUN apk del --purge -r other_deps
RUN rm -rf /tmp/blas /tmp/lapack /var/cache/apk/*
ADD start-notebook.sh /home/${USERNAME}
RUN chown ${USERNAME} /home/${USERNAME}/start-notebook.sh \
    && chmod a+x /home/${USERNAME}/start-notebook.sh
USER ${USERNAME}
WORKDIR /home/${USERNAME}

EXPOSE ${JUPYTER_NOTEBOOK_PORT}

ENTRYPOINT ["./start-notebook.sh"]


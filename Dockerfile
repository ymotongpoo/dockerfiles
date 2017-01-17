#   Copyright 2017 Yoshi Yamaguchi
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
FROM debian:sid
MAINTAINER Yoshi Yamaguchi <ymotongpoo@gmail.com>

ARG PYTHON_VER=3.6.0
ARG USERNAME=py36 

RUN touch /etc/apt/source.list \
    && echo "deb http://ftp.jp.debian.org/debian unstable main contrib non-free" >> /etc/apt/source.list \
    && echo "deb-src  http://ftp.jp.debian.org/debian unstable main contrib non-free" >> /etc/apt/source.list
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
  build-essential \
  wget \
  zlib1g-dev \
  bzip2 \
  libbz2-dev \
  libreadline6-dev \
  libjpeg62-turbo \
  libjpeg62-turbo-dev \
  libjpeg-dev \
  libsqlite3-0 \
  libsqlite3-dev \
  libgdbm3 \
  libgdbm-dev \
  libssl1.1 \
  libssl-dev \
  tk8.6-dev

RUN mkdir -p /opt/python/${PYTHON_VER}
WORKDIR /opt/python/
RUN wget https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tgz
RUN tar xzf Python-${PYTHON_VER}.tgz
WORKDIR /opt/python/Python-${PYTHON_VER}

RUN ./configure --prefix=/opt/python/${PYTHON_VER} \
                --with-threads \
                --with-computed-gotos \
                --enable-optimizations \
                --enable-ipv6 \
                --with-system-expat \
                --with-dbmliborder=gdbm:ndbm \
                --with-system-ffi \
                --with-system-libmpdec \
                --enable-loadable-sqlite-extensions

RUN make && make install

# clean up process
RUN rm -rf /opt/python/Python-${PYTHON_VER} && rm /opt/python/Python-${PYTHON_VER}
RUN apt-get clean

RUN useradd -d /home/${USERNAME} -m ${USERNAME}
USER ${USERNAME}
RUN touch /home/${USERNAME}/.bashrc \
    && echo 'PATH=/opt/python/${PYTHON_VER}/bin:$PATH' >> /home/${USERNAME}/.bashrc
WORKDIR /home/${USERNAME}



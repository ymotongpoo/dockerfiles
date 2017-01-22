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
FROM debian:sid
MAINTAINER Yoshi Yamaguchi <ymotongpoo@gmail.com>

LABEL version="1.0"

ARG USERNAME=golang
ARG BOOTSTRAP_GO_VER=1.7.4
ARG BOOTSTRAP_PREBUILT_GO_TGZ="go${BOOTSTRAP_GO_VER}.linux-amd64.tar.gz"
ARG BOOTSTRAP_PREBUILT_GO_SRC="https://storage.googleapis.com/golang/${BOOTSTRAP_PREBUILT_GO_TGZ}"
ARG GO_SOURCE_URL="https://go.googlesource.com/go"
ARG DEBIAN_WORKROOT=/home/${USERNAME}/dist
ENV GOROOT_BOOTSTRAP=/home/${USERNAME}/${BOOTSTRAP_GO_VER}/go

# install required apk packages
RUN touch /etc/apt/source.list \
    && echo "deb http://ftp.jp.debian.org/debian unstable main contrib non-free" >> /etc/apt/source.list \
    && echo "deb-src  http://ftp.jp.debian.org/debian unstable main contrib non-free" >> /etc/apt/source.list
RUN apt-get update && apt-get upgrade -y
RUN apt-get install --no-install-recommends --no-install-suggests -y \
      wget \
      ca-certificates \
      bash \
      build-essential \
      git \
      fakeroot
RUN useradd -d /home/${USERNAME} -m ${USERNAME}
ADD generate_package.sh /home/${USERNAME}
RUN chown ${USERNAME} /home/${USERNAME}/generate_package.sh \
    && chmod +x /home/${USERNAME}/generate_package.sh
USER ${USERNAME}
WORKDIR /home/${USERNAME}
RUN mkdir -p ${GOROOT_BOOTSTRAP}
RUN wget ${BOOTSTRAP_PREBUILT_GO_SRC} \
    && tar xzf ${BOOTSTRAP_PREBUILT_GO_TGZ} -C /home/${USERNAME}/${BOOTSTRAP_GO_VER} 
RUN git clone --depth=1 ${GO_SOURCE_URL} latest \
    && rm -rf !$/.git \
    && cd latest/src \
    && ./all.bash
WORKDIR /home/${USERNAME}
RUN mkdir -p ${DEBIAN_WORKROOT}/DEBIAN \
    && mkdir -p ${DEBIAN_WORKROOT}/opt/go \
    && ./generate_package.sh $(pwd) latest ${DEBIAN_WORKROOT} ${DEBIAN_WORKROOT}/opt/go

USER root

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
FROM alpine:latest
MAINTAINER Yoshi Yamaguchi <ymotongpoo@gmail.com>

LABEL version="0.5"

ARG USERNAME=ocaml

# install required apk packages
RUN apk update && apk upgrade
RUN apk add \
      wget \
      ca-certificates \
      bash \
      ocaml 

# set normal user
RUN adduser -s /bin/bash -D -h /home/${USERNAME} ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}
RUN mkdir -p /home/${USERNAME}/bin
RUN wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /home/${USERNAME}/bin


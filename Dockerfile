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
FROM ymotongpoo-docker-registry.bintray.io/python/debian-sid:3.6.0
MAINTAINER Yoshi Yamaguchi <ymotongpoo@gmail.com>

ARG PYTHON_VER=3.6.0
ENV JUPYTER_WORKDIR=jupyter
ENV JUPYTER_NOTEBOOK_PORT=8888
# add unstable package source list
RUN touch /etc/apt/source.list \
    && echo "deb http://ftp.jp.debian.org/debian unstable main contrib non-free" >> /etc/apt/source.list \
    && echo "deb-src  http://ftp.jp.debian.org/debian unstable main contrib non-free" >> /etc/apt/source.list
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y apt-utils
  file \
  libjpeg-dev \
  libtiff5 \
  libtiff5-dev \
  libwebp6 \
  libwebp-dev \
  liblapack3 \
  liblapack-dev \
  libatlas3-base \
  libatlas-dev

# setting for venv
RUN /opt/python/${PYTHON_VER}/bin/python3 -E -m venv ${JUPYTER_WORKDIR}
WORKDIR /home/py3/${JUPYTER_WORKDIR}
ADD requirements.txt .
USER root
RUN chown py3 ./requirements.txt
USER py3
RUN . bin/activate \
    && pip3 install -r requirements.txt

WORKDIR /home/py3
ADD start-notebook.sh .
USER root
RUN chown py3 start-notebook.sh
USER py3
RUN chmod a+x start-notebook.sh

EXPOSE ${JUPYTER_NOTEBOOK_PORT}
ENTRYPOINT ["start-notebook.sh"]

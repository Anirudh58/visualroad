FROM ubuntu:18.04
MAINTAINER Anirudh Prabakaran "anirudhprabakaran@gmail.com"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# create new user
RUN useradd -ms /bin/bash eva

USER eva
WORKDIR /home/eva

ENV OUTPUT_PATH=/app

ARG CARLA_VERSION=0.9.13
ARG CARLA_REPOSITORY=https://github.com/carla-simulator/carla
ENV CARLA_PATH=/home/eva/carla

ENV UNREAL_PATH=/home/eva/UnrealEngine_4.26
ENV UE4_ROOT $UNREAL_PATH

ENV DEBIAN_FRONTEND noninteractive

##############

USER root

# Install initial software requirements
RUN apt-get update
RUN apt-get install \
        -y \
        --no-install-recommends \
    wget \
    software-properties-common \
    gpg-agent

RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - 
RUN apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main"

# Install further software requirements
RUN apt-get update
RUN apt-get install \
        -y \
        --no-install-recommends \
      build-essential \
      clang-8 \
      lld-8 \
      g++-7 \
      cmake \
      ninja-build \
      libvulkan1 \
      python \
      python-pip \
      python-dev \
      python3-dev \
      python3-pip \
      libpng-dev \
      libtiff5-dev \
      libffi-dev \
      libjpeg-dev \
      tzdata \ 
      sed \ 
      curl \
      unzip \
      autoconf \
      automake \
      libtool \
      rsync \
      libxml2-dev \
      git

# Install clang-8 and LLVM's libc++
RUN apt-get install -y clang-8 lld-8 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180 && \
    update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180

# Remove root mode. Add new user
USER eva

# Upgrade pip
RUN pip3 install --upgrade pip
RUN pip install --upgrade pip

# pip dependencies
RUN pip install --user setuptools && \
    pip3 install --user -Iv setuptools==47.3.1 && \
    pip install --user distro && \
    pip3 install --user distro && \
    pip install --user wheel && \
    pip3 install --user wheel auditwheel 

# Setup Unreal engine (Add your github access token while cloning, since unreal engine repo is private)
RUN git clone --depth 1 -b carla https://github.com/CarlaUnreal/UnrealEngine.git $UNREAL_PATH && \
    cd $UNREAL_PATH && \
    ./Setup.sh && ./GenerateProjectFiles.sh && make


# CARLA build
RUN git clone https://github.com/carla-simulator/carla $CARLA_PATH && \
    cd $CARLA_PATH && \
    ./Update.sh

RUN echo 'export UE4_ROOT=/home/eva/UnrealEngine_4.26' >> ~/.bashrc
RUN source ~/.bashrc
WORKDIR $CARLA_PATH
RUN make package

# Install Carla Python API
RUN pip3 install --user --upgrade --ignore-installed -e $CARLA_PATH/PythonAPI/carla
# RUN pip2 install --user --upgrade --ignore-installed -e $CARLA_PATH/PythonAPI/carla




FROM ubuntu:18.04
MAINTAINER Anirudh Prabakaran "anirudhprabakaran@gmail.com"

# for source command
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Disable the default "lecture" message the first time a user runs a command using sudo
RUN echo 'Defaults lecture="never"' >> /etc/sudoers

# Unreal refuses to run as the root user, 
# so create a non-root user with no password and allow them to run commands using sudo
RUN useradd --create-home --home /home/eva --shell /bin/bash --uid 1000 eva && \
	passwd -d eva && \
	usermod -a -G audio,video,sudo eva

ENV OUTPUT_PATH=/app

ARG CARLA_VERSION=0.9.13
ARG CARLA_REPOSITORY=https://github.com/carla-simulator/carla
ENV CARLA_PATH=/home/eva/carla

ENV UNREAL_VERSION=4.26
ENV UNREAL_PATH=/home/eva/UnrealEngine_4.26
ENV UE4_ROOT $UNREAL_PATH

ARG VISUALROAD_VERSION=master
ARG VISUALROAD_REPOSITORY=https://github.com/uwdb/visualroad.git
ENV VISUALROAD_PATH=/home/eva/visualroad

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

##############

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

# Setup Unreal engine (Add your github access token while cloning, 
# since unreal engine repo is private)
RUN git clone --depth 1 -b carla https://Anirudh58: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@github.com/CarlaUnreal/UnrealEngine.git $UNREAL_PATH && \
    cd $UNREAL_PATH && \
    ./Setup.sh && ./GenerateProjectFiles.sh && make

# CARLA build
RUN git clone https://github.com/carla-simulator/carla $CARLA_PATH && \
    cd $CARLA_PATH && \
    git checkout $CARLA_VERSION && \
    ./Update.sh && \
    echo 'export UE4_ROOT=/home/eva/UnrealEngine_4.26' >> ~/.bashrc && \
    source ~/.bashrc && \
    make package

# Install Carla Python API
RUN pip2 install --user --upgrade --ignore-installed -e $CARLA_PATH/PythonAPI/carla & \
    pip3 install --user --upgrade --ignore-installed -e $CARLA_PATH/PythonAPI/carla

# Install Visual Road
RUN git clone $VISUALROAD_REPOSITORY $VISUALROAD_PATH && \
    cd $VISUALROAD_PATH && \
    git checkout $VISUALROAD_VERSION

USER root

# Packages required for opencv
RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6 xdg-user-dirs  -y

USER eva

# Install other Python packages
RUN pip2 install --user numpy pyyaml opencv-python psutil & \
    pip3 install --user numpy pyyaml opencv-python psutil


ENV CARLA_EXECUTABLE=$CARLA_PATH/Unreal/CarlaUE4/Saved/StagedBuilds/LinuxNoEditor/CarlaUE4/Binaries/Linux/CarlaUE4-Linux-Shipping


WORKDIR /home/eva/visualroad

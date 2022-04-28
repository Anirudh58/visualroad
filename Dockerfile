FROM carlasim/carla:0.9.13
MAINTAINER Anirudh Prabakaran "anirudhprabakaran@gmail.com"

USER root

# for source command
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Disable the default "lecture" message the first time a user runs a command using sudo
RUN echo 'Defaults lecture="never"' >> /etc/sudoers

# Unreal refuses to run as the root user, 
# so create a non-root user with no password and allow them to run commands using sudo
RUN useradd --create-home --home /home/eva --shell /bin/bash --uid 1001 eva && \
	passwd -d eva && \
	usermod -a -G audio,video,sudo eva

# Define variables

ENV CARLA_PATH=/home/carla
ENV CARLA_EXECUTABLE=$CARLA_PATH/CarlaUE4.sh

ARG VISUALROAD_VERSION=master
ARG VISUALROAD_REPOSITORY=https://github.com/uwdb/visualroad.git
ENV VISUALROAD_PATH=/home/eva/visualroad

ENV DEBIAN_FRONTEND noninteractive

###############



# Install initial software requirements
RUN apt-get update
RUN apt-get install \
        -y \
        --no-install-recommends \
    wget \
    software-properties-common \
    gpg-agent


# Install further software requirements
RUN apt-get update
RUN apt-get install \
        -y \
        --no-install-recommends \
      python \
      python-pip \
      python-dev \
      python3-dev \
      python3-pip \
      libtiff5-dev \
      libjpeg-dev \
      sed \ 
      curl \
      unzip \
      git \ 
      vim \ 
      xdg-user-dirs \
      ffmpeg

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

# install Carla client
RUN pip install --user carla && \
    pip3 install --user carla

# Install other Python packages
RUN pip2 install --user numpy pyyaml opencv-python psutil & \
    pip3 install --user numpy pyyaml opencv-python psutil

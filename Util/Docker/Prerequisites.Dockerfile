FROM ubuntu:18.04

USER root

ARG ssh_prv_key
ARG ssh_pub_key

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update ; \
  apt-get install -y wget software-properties-common && \
  add-apt-repository ppa:ubuntu-toolchain-r/test && \
  wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - && \
  apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" && \
  apt-get update ; \
  apt-get install -y build-essential \
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
    libjpeg-dev \
    tzdata \
    sed \
    curl \
    unzip \
    autoconf \
    libtool \
    rsync \
    libxml2-dev \
    git \
    aria2 && \
  pip3 install -Iv setuptools==47.3.1 && \
  pip3 install distro && \
  update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180 && \
  update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180

RUN useradd -m carla
COPY --chown=carla:carla . /home/carla
USER carla
WORKDIR /home/carla
ENV UE4_ROOT /home/carla/UE4.26

# Authorize SSH Host
RUN mkdir -p /home/carla/.ssh && \
    chmod 0700 /home/carla/.ssh && \
    ssh-keyscan github.com > /home/carla/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /home/carla/.ssh/id_github && \
    echo "$ssh_pub_key" > /home/carla/.ssh/id_github.pub && \
    chmod 600 /home/carla/.ssh/id_github && \
    chmod 600 /home/carla/.ssh/id_github.pub && \
    cat /home/carla/.ssh/id_github.pub && \
    cat /home/carla/.ssh/id_github

RUN git clone --depth 1 -b carla "git@github.com:CarlaUnreal/UnrealEngine.git" ${UE4_ROOT}

RUN cd $UE4_ROOT && \
  ./Setup.sh && \
  ./GenerateProjectFiles.sh && \
  make

# Remove SSH keys
RUN rm -rf /home/carla/.ssh/

WORKDIR /home/carla/

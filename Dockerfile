FROM amazonlinux:2017.03.1.20170812
MAINTAINER Paul Reimer <paul@p-rimes.net>

# From: https://aws.amazon.com/blogs/compute/introducing-the-c-lambda-runtime/
RUN \
  yum -y install \
    binutils \
    clang6.0 \
    git \
    libcurl-devel \
    ninja-build \
    tar \
    zip \
  && rm -rf /var/cache/yum

RUN \
  cd /tmp \
  && curl -fL \
    -o cmake-install \
    https://github.com/Kitware/CMake/releases/download/v3.13.0/cmake-3.13.0-Linux-x86_64.sh \
  && sh cmake-install --skip-license --prefix=/usr --exclude-subdirectory \
  && rm cmake-install

RUN \
  git clone https://github.com/awslabs/aws-lambda-cpp.git /tmp/aws-lambda-cpp \
  && cd /tmp/aws-lambda-cpp \
  && mkdir build \
  && cd build \
  && cmake .. -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=/opt/local \
  && ninja-build \
  && ninja-build install \
  && cd \
  && rm -rf /tmp/aws-lambda-cpp

ADD . /tmp/handler

RUN \
  cd /tmp/handler \
  && mkdir build \
  && cd build \
  && cmake .. -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/opt/local \
  && ninja-build -v \
  && ninja-build aws-lambda-package-example \
  && cp *.zip / \
  && cd \
  && rm -rf /tmp/handler

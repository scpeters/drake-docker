FROM ros:indigo-ros-base

ENV WS /root/ws
RUN mkdir -p ${WS}/src
WORKDIR ${WS}

#ENV DOCKER_REINSTALL_DEPS 000

# get basic utilities for ppa's
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
    lsb-core \
    software-properties-common \
    wget \
 && rm -rf /var/lib/apt/lists/*

# gcc 4.9
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    g++-4.9-multilib \
    gfortran-4.9 \
 && rm -rf /var/lib/apt/lists/*

# clang 3.7
RUN wget -q -O - http://llvm.org/apt/llvm-snapshot.gpg.key \
  | apt-key add - \
 && add-apt-repository -y "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.7 main" \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    clang-3.7 \
 && rm -rf /var/lib/apt/lists/*

# cmake 3.5
RUN wget https://cmake.org/files/v3.5/cmake-3.5.2-Linux-x86_64.tar.gz \
 && tar xf cmake-3.5.2-Linux-x86_64.tar.gz -C /usr --strip=1 \
 && rm cmake-3.5.2-Linux-x86_64.tar.gz

# install packages
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    python-catkin-tools \
    ros-indigo-ackermann-msgs \
    ros-indigo-tf \
    \
    autoconf \
    automake \
    bison \
    default-jdk \
    doxygen \
    flex \
    freeglut3-dev \
    git \
    graphviz \
    libgtk2.0-dev \
    libhtml-form-perl \
    libjpeg-dev \
    libmpfr-dev \
    libwww-perl \
    libpng-dev \
    libqt4-dev \
    libqt4-opengl-dev \
    libqwt-dev \
    libterm-readkey-perl \
    libtool \
    libvtk-java \
    libvtk5-dev \
    libvtk5-qt4-dev \
    make \
    mpich \
    ninja-build \
    perl \
    pkg-config \
    python-bs4 \
    python-dev \
    python-gtk2 \
    python-html5lib \
    python-numpy \
    python-pip \
    python-sphinx \
    python-vtk \
    subversion \
    swig \
    unzip \
    valgrind \
 && rm -rf /var/lib/apt/lists/*

# clone drake repository
RUN cd ${WS}/src \
 && git clone https://github.com/RobotLocomotion/drake.git \
 && ln -s $PWD/drake/ros $PWD/drake_ros_integration

# clone catkin
RUN cd ${WS}/src \
 && git clone https://github.com/ros/catkin.git

# fortran compilers
ENV FC gfortran-4.9
ENV F77 gfortran-4.9

# c/c++ compilers
ENV CC gcc-4.9
ENV CXX g++-4.9
#ENV CC clang-3.7
#ENV CXX clang++-3.7

# catkin workspace
RUN catkin init \
 && catkin config --cmake-args -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
 && catkin build -i

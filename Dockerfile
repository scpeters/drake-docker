FROM osrf/ros:indigo-desktop

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
RUN . /opt/ros/indigo/setup.sh \
 && catkin init \
 && catkin config --cmake-args -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
 && catkin build --limit-status-rate 1

# roslaunch shortcuts
RUN echo "roslaunch drake_cars_examples single_car_in_stata_garage.launch" > run_cars_example.sh

# Instead of installing nvidia drivers, use nvidia-docker-plugin
# Set environment variables to look for attached nvidia-docker volume
# This shouldn't interfere with other GPU implementations
# These lines were copied from cuda 7.5 Dockerfile
# https://github.com/NVIDIA/nvidia-docker/blob/v1.0.0-rc.3/ubuntu-14.04/cuda/7.5/runtime/Dockerfile#L4
# https://github.com/NVIDIA/nvidia-docker/blob/v1.0.0-rc.3/ubuntu-14.04/cuda/7.5/runtime/Dockerfile#L37-L38
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

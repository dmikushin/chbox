FROM centos:7

RUN yum install -y gcc make wget libtool xz git libcap-devel && \
    git config --global user.email "docker@chbox.com" && \
    git config --global user.name "Docker Container"

RUN wget --no-check-certificate https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.xz && \
    tar xf autoconf-2.71.tar.xz && \
    cd autoconf-2.71/ && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf autoconf-2.71

RUN wget https://github.com/Kitware/CMake/releases/download/v3.27.4/cmake-3.27.4-linux-x86_64.tar.gz && \
    tar xf cmake-3.27.4-linux-x86_64.tar.gz

env PATH=/cmake-3.27.4-linux-x86_64/bin:$PATH

RUN git clone https://github.com/dmikushin/chbox.git && \
    cd chbox && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/chbox_install -DTARGET_DISTRO="CentOS-7" -DDISABLE_FILE_OFFSET_BITS=ON .. && \
    make && \
    cpack

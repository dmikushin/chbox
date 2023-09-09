FROM rockylinux:8.8

RUN dnf install -y cmake gcc wget libtool xz git patch

RUN wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.xz && \
    tar xf autoconf-2.71.tar.xz && \
    cd autoconf-2.71/ && \
    ./configure && \
    make && \
    make install

RUN git clone https://github.com/dmikushin/chbox.git && \
    cd chbox && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/chbox_install -DDISABLE_HAVE_CAPSET=ON .. && \
    make && \
    cpack

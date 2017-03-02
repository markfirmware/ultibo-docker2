FROM resin/armv7hf-debian-qemu

RUN [ "cross-build-start" ]

WORKDIR /root

RUN apt-get update && apt-get install -y libgtk2.0-dev
RUN apt-get update && apt-get install -y wget binutils gcc bzip2 libc-dev make unzip libghc-x11-dev curl binutils-arm-none-eabi

COPY install.fpc-3.0.raspberry.sh .
RUN ./install.fpc-3.0.raspberry.sh
ENV PATH=/root/Development/FreePascal/fpc/bin:$PATH

RUN fpc -i && \
\
    wget -q https://github.com/ultibohub/FPC/archive/master.zip && \
    unzip -q master.zip && \
    rm master.zip && \
    mkdir -p /root/ultibo/core && \
    mv FPC-master /root/ultibo/core/fpc && \
    wget -q https://github.com/ultibohub/Core/archive/master.zip && \
    unzip -q master.zip && \
    rm master.zip && \
    mkdir -p /root/ultibo/core/fpc/source/packages && \
    mv Core-master/source/rtl/ultibo /root/ultibo/core/fpc/source/rtl && \
    mv Core-master/source/packages/ultibounits /root/ultibo/core/fpc/source/packages && \
    mv Core-master/units /root/ultibo/core/fpc && \
    rm -rf Core-master

WORKDIR /root/ultibo/core/fpc/source

RUN make distclean && \
    make all OPT=-dFPC_ARMHF && \
    make install OPT=-dFPC_ARMHF PREFIX=/root/ultibo/core/fpc && \
    cp /root/ultibo/core/fpc/source/compiler/ppcarm /root/ultibo/core/fpc/bin && \
    /root/ultibo/core/fpc/bin/fpcmkcfg -d basepath=/root/ultibo/core/fpc/lib/fpc/3.1.1 -o /root/ultibo/core/fpc/bin/fpc.cfg

ENV PATH=/root/ultibo/core/fpc/bin:$PATH

COPY make-platforms.sh .
RUN fpc -i && \
    ./make-platforms.sh

WORKDIR /test
RUN apt-get update && apt-get install -y git
COPY test-with-examples.sh .
RUN ./test-with-examples.sh

WORKDIR /workdir

RUN [ "cross-build-end" ]

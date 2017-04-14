FROM node

WORKDIR /root

RUN apt-get update && apt-get install -y wget binutils gcc git && \
    wget -q -O fpc_3.0.0-151205_amd64.deb 'http://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.2/fpc_3.0.0-151205_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.2%2F&ts=1483204950&use_mirror=superb-sea2' && \
    dpkg -i fpc_3.0.0-151205_amd64.deb && \
    rm fpc_3.0.0-151205_amd64.deb && \
    fpc -i

RUN apt-get update && apt-get install -y bzip2 libc-dev libc6-i386 make unzip && \
    wget -q https://github.com/ultibohub/FPC/archive/master.zip && \
    unzip -q master.zip && \
    rm master.zip && \
    mkdir -p $HOME/ultibo/core && \
    mv FPC-master ultibo/core/fpc && \
    wget -q https://github.com/ultibohub/Core/archive/master.zip && \
    unzip -q master.zip && \
    rm master.zip && \
    mkdir -p $HOME/ultibo/core/fpc/source/packages && \
    mv Core-master/source/rtl/ultibo $HOME/ultibo/core/fpc/source/rtl && \
    mv Core-master/source/packages/ultibounits $HOME/ultibo/core/fpc/source/packages && \
    mv Core-master/units $HOME/ultibo/core/fpc && \
    rm -rf Core-master
 
WORKDIR /root/ultibo/core/fpc/source

RUN make distclean && \
    make all OS_TARGET=linux CPU_TARGET=x86_64 && \
    make install OS_TARGET=linux CPU_TARGET=x86_64 INSTALL_PREFIX=$HOME/ultibo/core/fpc && \
\
    cp compiler/ppcx64 ../bin/ppcx64 && \
    ../bin/fpcmkcfg -d basepath=$HOME/ultibo/core/fpc/lib/fpc/3.1.1 -o $HOME/ultibo/core/fpc/bin/fpc.cfg && \
    ../bin/fpc -i

ENV PATH=/root/ultibo/core/fpc/bin:$PATH

RUN wget -q https://launchpadlibrarian.net/287101520/gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar.bz2 && \
    bunzip2 gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar.bz2 && \
    tar xf gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar && \
    rm gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/as $HOME/ultibo/core/fpc/bin/arm-ultibo-as && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/ld $HOME/ultibo/core/fpc/bin/arm-ultibo-ld && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/objcopy $HOME/ultibo/core/fpc/bin/arm-ultibo-objcopy && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/objdump $HOME/ultibo/core/fpc/bin/arm-ultibo-objdump && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/strip $HOME/ultibo/core/fpc/bin/arm-ultibo-strip && \
    rm -rf gcc-arm-none-eabi-5_4-2016q3/

RUN make distclean OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/ppcx64 && \
    make all OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/ppcx64 && \
    make crossinstall BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=$HOME/ultibo/core/fpc/bin/ppcx64 INSTALL_PREFIX=$HOME/ultibo/core/fpc && \
\
    cp $HOME/ultibo/core/fpc/source/compiler/ppcrossarm $HOME/ultibo/core/fpc/bin/ppcrossarm

COPY make-platforms.sh .
RUN ./make-platforms.sh

RUN apt-get update && apt-get install -y qemu-system-arm python-pip imagemagick && \
    pip install parse

WORKDIR /test
COPY test-with-examples.sh .
RUN ./test-with-examples.sh

WORKDIR /workdir

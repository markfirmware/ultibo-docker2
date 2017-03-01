#!/bin/bash

set -x
mkdir -p github.com/ultibohub
cd github.com/ultibohub
git clone https://github.com/ultibohub/Examples
cd Examples
set +x

INCLUDES=-Fi/root/ultibo/core/fpc/source/packages/fv/src

function build {
    echo ......................... building *.lpr for target $1
    rm -f *.o
    set -x
    fpc \
     -B \
     -Tultibo \
     -O2 \
     -Parm \
     $2 \
     $INCLUDES \
     @/root/ultibo/core/fpc/bin/$3 \
     *.lpr
    EXIT_STATUS=$?
    set +x
    if [ "$EXIT_STATUS" != 0 ]
    then
        exit 1
    fi
}

function build-QEMU {
    build QEMU "-CpARMV7A -WpQEMUVPB" qemuvpb.cfg
}

function build-RPi {
    build RPi "-CpARMV6 -WpRPIB" rpi.cfg
}

function build-RPi2 {
    build RPi2 "-CpARMV7A -WpRPI2B" rpi2.cfg
}

function build-RPi3 {
    build RPi3 "-CpARMV7A -WpRPI3B" rpi3.cfg
}

for EXAMPLE in [0-9][0-9]-*
do
    cd $EXAMPLE
    echo
    echo $EXAMPLE
    for TARGET in *
    do
        cd $TARGET
        build-$TARGET
        cd ..
    done
    cd ..
done

rm -rf /root/github.com

#!/bin/bash

function makecfg {
    CFGFILE=$1
    ARMVFOLDER=$2
    VFPV=$3
    COMMENT=$4

    cat <<__EOF__ > $ULTIBODIR/bin/$CFGFILE
#
# $COMMENT specific config file
#
-Cf$VFPV
-CIARM
-CaEABIHF
-OoFASTMATH
-Fu$ULTIBODIR/units/$ARMVFOLDER-ultibo/rtl
-Fu$ULTIBODIR/units/$ARMVFOLDER-ultibo/packages
-Fl$ULTIBODIR/units/$ARMVFOLDER-ultibo/lib
-XParm-none-eabi-
__EOF__
}

function runmake {
    make $* \
        OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=${ARMV,,} \
        CROSSOPT="-Cp$ARMV -Cf$VFPV -CIARM -CaEABIHF -OoFASTMATH $EXTRACROSSOPT" \
        FPCFPMAKE=$FPCEXE \
        FPC=$FPCEXE \
        BINUTILSPREFIX=arm-none-eabi-
}

function makeplatform {
    ARMVFOLDER=$1
    ARMV=$2
    VFPV=$3

    runmake rtl_clean \
        CROSSINSTALL=1 && \
    runmake rtl && \
    runmake rtl_install \
        CROSSINSTALL=1 \
        INSTALL_PREFIX=$ULTIBODIR \
        INSTALL_UNITDIR=$ULTIBODIR/units/$ARMVFOLDER-ultibo/rtl && \
    runmake rtl_clean \
        CROSSINSTALL=1 && \
    runmake packages_clean \
        CROSSINSTALL=1 && \
    EXTRACROSSOPT=-Fu$ULTIBODIR/units/$ARMVFOLDER-ultibo/rtl && \
    runmake packages && \
    EXTRACROSSOPT="" && \
    runmake packages_install \
        CROSSINSTALL=1 \
        INSTALL_PREFIX=$ULTIBODIR \
        INSTALL_UNITDIR=$ULTIBODIR/units/$ARMVFOLDER-ultibo/packages
}

ULTIBODIR=$HOME/ultibo/core/fpc
FPCEXE=$ULTIBODIR/bin/fpc
makecfg rpi.cfg armv6 VFPV2 "Raspberry Pi (A/B/A+/B+/Zero)" && \
makecfg rpi2.cfg armv7 VFPV3 "Raspberry Pi 2B" && \
makecfg rpi3.cfg armv7 VFPV3 "Raspberry Pi 3B" && \
makecfg qemuvpb.cfg armv7 VFPV3 "QEMU armv7a" && \
head -20 $ULTIBODIR/bin/*.cfg && \
makeplatform armv7 ARMV7A VFPV3 && \
makeplatform armv6 ARMV6 VFPV2

#!/usr/bin/env bash
#
# Script to build kernel for apollo
# By Chirayu Desai (cdesai)

COMMAND=$1
TOP=${PWD}
CURRENT_DIR=`dirname $0`

KERNEL_SRC=${TOP}/kernel
KERNEL_DEFCONFIG=apollo_defconfig
OUT=${TOP}/out
KERNEL_OUT=${TOP}/out/kernel

# Common defines (Arch-dependent)
case `uname -s` in
	Darwin)
		txtrst='\033[0m'  # Color off
		txtred='\033[0;31m' # Red
		txtgrn='\033[0;32m' # Green
		txtylw='\033[0;33m' # Yellow
		txtblu='\033[0;34m' # Blue
		THREADS=`sysctl -an hw.logicalcpu`
		;;
	*)
		txtrst='\e[0m'  # Color off
		txtred='\e[0;31m' # Red
		txtgrn='\e[0;32m' # Green
		txtylw='\e[0;33m' # Yellow
		txtblu='\e[0;34m' # Blue
		THREADS=`cat /proc/cpuinfo | grep processor | wc -l`
		;;
esac

if [ -z ${CROSS_COMPILE} ]; then
if [! -z ${ANDROID_BUILD_TOP} ]; then
CROSS_COMPILE=${ANDROID_BUILD_TOP}/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-
else
CROSS_COMPILE=arm-eabi-
fi
fi

do_build()
{
    mkdir -p ${OUT}
    mkdir -p ${KERNEL_OUT}
    make -j${THREADS} -C ${KERNEL_SRC} O=${KERNEL_OUT} ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} ${KERNEL_DEFCONFIG}
    echo "Building"
    make -j${THREADS} -C ${KERNEL_SRC} O=${KERNEL_OUT} ARCH=arm CROSS_COMPILE=${CROSS_COMPILE}
    echo "Building modules"
    make -j${THREADS} -C ${KERNEL_SRC} O=${KERNEL_OUT} ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} modules
    echo "Copying kernel"
    cp ${KERNEL_OUT}/arch/arm/boot/zImage ${OUT}/zImage
    echo "Done. zImage can be found at ${OUT}/zImage"
}

do_clean()
{
    echo "Cleaning"
    rm -rf ${OUT}
}

show_help()
{
echo "Kernel buildscript"
echo "By Chirayu Desai"
echo
echo "Usage: $0 <command>"
echo "Supported commands:"
echo "build: builds the kernel"
echo "clean: removes all generated files"
echo "help: shows this help message"
echo "sync: syncs sources"
}

do_sync()
{
    echo "Syncing sources"
    repo sync
}

case ${COMMAND} in
    build)
    do_clean
    do_build
    ;;
    clean)
    do_clean
    ;;
    help)
    show_help
    ;;
    sync)
    do_sync
    ;;
    *)
    echo "Y u no pass an argument"
    echo
    show_help
    ;;
esac

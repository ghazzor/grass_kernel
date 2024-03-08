#/bin/bash
set -e

[ ! -e "scripts/packaging/pack.sh" ] && git submodule init && git submodule update
[ ! -d "toolchain" ] && echo "Make toolchain avaliable at $(pwd)/toolchain" && exit

export KBUILD_BUILD_USER=Royna
export KBUILD_BUILD_HOST=GrassLand

PATH=$PWD/toolchain/bin:$PATH
export LLVM_DIR=$PWD/toolchain/bin
export kerneldir=$PWD

if [ "$1" = "oneui" ]; then
FLAGS=ONEUI=1
else
CONFIG_AOSP=vendor/aosp.config
fi

if [ -z "$DEVICE" ]; then
export DEVICE=m21
fi

if [ "$2" = "ksu" ]; then
  CONFIG_KSU=vendor/ksu.config
elif [ "$2" = "no-ksu" ]; then
  CONFIG_KSU=vendor/no-ksu.config
fi


CONFIG_KSU=vendor/no-ksu.config
fi

rm -rf out

COMMON_FLAGS='
CC=clang
LD=ld.lld
ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-
CLANG_TRIPLE=aarch64-linux-gnu-
AR='${LLVM_DIR}/llvm-ar'
NM='${LLVM_DIR}/llvm-nm'
AS='${LLVM_DIR}/llvm-as'
OBJCOPY='${LLVM_DIR}/llvm-objcopy'
OBJDUMP='${LLVM_DIR}/llvm-objdump'
READELF='${LLVM_DIR}/llvm-readelf'
OBJSIZE='${LLVM_DIR}/llvm-size'
STRIP='${LLVM_DIR}/llvm-strip'
LLVM_AR='${LLVM_DIR}/llvm-ar'
LLVM_DIS='${LLVM_DIR}/llvm-dis'
LLVM_NM='${LLVM_DIR}/llvm-nm'
'

make O=out $COMMON_FLAGS vendor/${DEVICE}_defconfig vendor/grass.config vendor/${DEVICE}.config $CONFIG_AOSP $CONFIG_KSU
make O=out $COMMON_FLAGS ${FLAGS} -j$(nproc)

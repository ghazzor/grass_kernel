[ ! -e "KernelSU/kernel/setup.sh" ] && git submodule init && git submodule update
[ ! -d "toolchain" ] && echo "Toolchain not avaliable at $(pwd)/toolchain... installing toolchain" && bash setup.sh

export KBUILD_BUILD_USER=Royna
export KBUILD_BUILD_HOST=GrassLand

PATH=$PWD/toolchain/bin:$PATH
export LLVM_DIR=$PWD/toolchain/bin
export kerneldir=$PWD
export ANYKERNEL=$PWD/tools/build/akv3
export TIME="$(date "+%Y%m%d")"

if [ "$1" = "oneui" ]; then
FLAGS=ONEUI=1
SUFFIX=ONEUI
else
CONFIG_AOSP=vendor/aosp.config
SUFFIX=AOSP
fi

if [ -z "$DEVICE" ]; then
export DEVICE=m21
fi

if [ "$2" = "ksu" ]; then
  CONFIG_KSU=vendor/ksu.config
export KSUSTAT=KSU
elif [ "$2" = "no-ksu" ]; then
  CONFIG_KSU=vendor/no-ksu.config
export KSUSTAT=N
fi

if [ "$3" = "permissive" ]; then
CONFIG_SELINUX=vendor/permissive.config
export SESTAT=P
else
export SESTAT=E
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

make distclean
mkdir -p kernel_zip
make O=out $COMMON_FLAGS vendor/${DEVICE}_defconfig vendor/grass.config vendor/${DEVICE}.config $CONFIG_AOSP $CONFIG_KSU $CONFIG_SELINUX
make O=out $COMMON_FLAGS ${FLAGS} -j$(nproc)

echo "  Cleaning Stuff"
rm -rf ${ANYKERNEL}/Image
rm -rf ${ANYKERNEL}/config
echo "  done"
echo ""
echo "  Copying Stuff"

locations=(
  "${kerneldir}/arch/arm64/boot"
  "${kerneldir}/out/arch/arm64/boot"
)

found=false
for location in "${locations[@]}"; do
  if test -f "$location/Image"; then
    found=true
    break
  fi
done

if ! $found; then
  echo "  ERROR : image binary not found in any of the specified locations , fix compile!"
  exit 1
fi

cp -r out/arch/arm64/boot/Image ${ANYKERNEL}/Image
cp -r out/.config ${ANYKERNEL}/config
echo "  done"
echo ""
echo "  Zipping Stuff"
cd ${ANYKERNEL}
rm -rf Grass*.zip
zip -r9 Grass-${SUFFIX}-$DEVICE_${KSUSTAT}_${SESTAT}_${TIME}.zip * -x .git README.md *placeholder
cd ${kerneldir}
cp ${ANYKERNEL}/Grass*.zip kernel_zip/
echo "  Kernel zip in ${kerneldir}/kernel_zip"
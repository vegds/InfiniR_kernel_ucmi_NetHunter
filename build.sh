#!/bin/bash

# CHANGE THE PATH TO YOUR TOOLCHAINS

# ===----------------------------------------------=== #
# This script is used to build android kernel for mi10 #
# ===----------------------------------------------=== #

# ===------------=== #
# Clone Dependencies #
# ===------------=== #

echo "[+] prepare dependencies"

NETHUNTER_KERNEL_DIR="kali-nethunter-kernel"
NETHUNTER_PROJECT_DIR="kali-nethunter-project"

if [ -d "$NETHUNTER_KERNEL_DIR" ]; then
    echo "[+] $NETHUNTER_KERNEL_DIR exits"
    cd $(pwd)/$NETHUNTER_KERNEL_DIR
    git pull
    cd ..
else 
    echo "[!] $NETHUNTER_KERNEL_DIR not exits, start cloning..."
    git clone https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel.git
fi

echo -n "[!] Adding patch fix-ath9k-naming-conflict.patch? [y/N]"
read -r fix_ath9k_naming_conflict
if [ "$fix_ath9k_naming_conflict" == "Y" ] || [ "$fix_ath9k_naming_conflict" == "y" ]; then
    patch -p1 < kali-nethunter-kernel/patches/4.19/fix-ath9k-naming-conflict.patch
fi

echo -n "[!] Adding patch fix-ath9k-naming-conflict.patch? [y/N]"
read -r add_wifi_injection
if [ "$add_wifi_injection" == "Y" ] || [ "$add_wifi_injection" == "y" ]; then
    patch -p1 < kali-nethunter-kernel/patches/4.19/add-wifi-injection-4.14.patch
fi

if [ -d "$NETHUNTER_PROJECT_DIR" ]; then
    echo "[+] $NETHUNTER_PROJECT_DIR exits"
    cd $(pwd)/$NETHUNTER_PROJECT_DIR
    git pull
    cd ..
else 
    echo "[!] $NETHUNTER_PROJECT_DIR not exits, start cloning..."
    git clone https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-project --depth=1
fi

mkdir -p $(pwd)/kali-nethunter-project/nethunter-installer/devices

cat << EOL > kali-nethunter-project/nethunter-installer/devices/devices.cfg
# Xiaomi 10 for HyperOS Android 14
[umi]
author = "Yttehs"
arch = arm64
version = "v1.1"
flasher = anykernel
modules = 1
slot_device = 0
block = /dev/block/bootdevice/by-name/boot
devicenames = umi,Mi10
EOL

echo "[+] fetch KenrelSU"
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -

echo "[+] copy defconfig"
cp $(pwd)/umi_nethunter_defconfig $(pwd)/arch/arm64/configs/umi_nethunter_defconfig

# ===-----------------=== #
# Buiding Kernel & Module #
# ===-----------------=== #

echo "[+] start building"

TOOLCHAIN_PATH="/home/yttehs/Project/Kernel-Dev/toolchains"

CLANG_VERSION="17"
GCC_VERSION="4.9"
O="out"
ARCH="arm64"

CLANG_PATH="${TOOLCHAIN_PATH}/zyc-${CLANG_VERSION}/bin"
GCC32_PATH="${TOOLCHAIN_PATH}/gcc32-${GCC_VERSION}/bin"
GCC_PATH="${TOOLCHAIN_PATH}/gcc-${GCC_VERSION}/bin"

echo "[!] setting up environment"

echo "[+] clang path: ${CLANG_PATH}"
echo "[+] gcc32 path: ${GCC32_PATH}"
echo "[+] gcc path: ${GCC_PATH}"

export PATH="${CLANG_PATH}:${GCC32_PATH}:${GCC_PATH}:${PATH}"

args="-j$(nproc --all) \
O=${O} \
ARCH=${ARCH} \
CROSS_COMPILE=aarch64-linux-gnu- \
CROSS_COMPILE_ARM32=arm-linux-androideabi- \
CLANG_TRIPLE=aarch64-linux-gnu- \
CC=clang \
LD=ld.lld \
AR=llvm-ar \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
OBJDUMP=llvm-objdump \
READELF=llvm-readelf \
OBJSIZE=llvm-size \
STRIP=llvm-strip \
LDGOLD=aarch64-linux-gnu-ld.gold \
LLVM_AR=llvm-ar \
LLVM_DIS=llvm-dis"

echo "[!] cleanning old configuration"
make mrproper

echo "[!] executing defconfig"
make ${args} umi_nethunter_defconfig

echo "[!] compiling"
make ${args} 2>&1

echo "[!] compiling modules"
make ${args} INSTALL_MOD_PATH="." INSTALL_MOD_STRIP=1 modules_install

# ===-----------------------------=== #
# | Create NetHunter-Anykernel3 Zip | #
# ===-----------------------------=== #

echo "[+] start packaging"

O=out
ARCH=arm64
KERNEL_VERSION="4.19.305-InfiniR-NetHunter"
DEVICE=umi
ANDROID_VERSION=thirteen

echo "[+] create dirs"
mkdir -p $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE
mkdir -p $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE/modules/system/lib/modules

echo "[!] clean pre files"
rm -rf $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE/Image
rm -rf $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE/dtbo.img
rm -rf $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE/dtb
rm -rf $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE/modules/system/lib/modules/*

echo "[+] copy Image"
cp $(pwd)/$O/arch/$ARCH/boot/Image $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE
echo "[+] copy dtbo.img"
cp $(pwd)/$O/arch/$ARCH/boot/dtbo.img $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE
echo "[+] copy dtb"
cp $(pwd)/$O/arch/$ARCH/boot/dtb $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE

echo "[!] delete links"
rm -rf $(pwd)/$O/lib/modules/$KERNEL_VERSION/source
rm -rf $(pwd)/$O/lib/modules/$KERNEL_VERSION/build

echo "[+] copy modules"
cp -r $(pwd)/$O/lib/modules/$KERNEL_VERSION $(pwd)/kali-nethunter-project/nethunter-installer/devices/$ANDROID_VERSION/$DEVICE/modules/system/lib/modules/

cd $(pwd)/kali-nethunter-project/nethunter-installer/
python3 build.py -d umi --thirteen --kernel
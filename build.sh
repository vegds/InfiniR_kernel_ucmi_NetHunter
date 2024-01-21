#! /usr/bin/bash

# CHANGE THE PATH TO YOUR TOOLCHAINS

# ===----------------------------------------------=== #
# This script is used to build android kernel for mi10 #
# ===----------------------------------------------=== #

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

echo "[!] cleanning old builds"
rm -rf $(pwd)/${O}

echo "[!] executing defconfig"
make ${args} umi_nethunter_defconfig

echo "[!] compiling"
make ${args} 2>&1

echo "[!] compiling modules"
make ${args} INSTALL_MOD_PATH="." INSTALL_MOD_STRIP=1 modules_install
#!/bin/bash

# ===---------------------------------------------------------===
# | this script is used to create NetHunter-Anykernel3 zip file |
# ===---------------------------------------------------------===

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
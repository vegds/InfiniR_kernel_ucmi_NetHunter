# Kernel Characteristics:

### Compiler

**Clang**: [ZyCromerZ/Clang 17.0.0](https://github.com/ZyCromerZ/Clang/releases/tag/17.0.0-20230725-release)

## KenrelSU
Please run the following step brfore building.
```bash
cd /path/to/kernel/source
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
```

## NetHunter

I've completed the steps below, so you don't have to do again.

```bash
cd /path/to/kernel/source
git clone https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel.git
patch -p1 < kali-nethunter-kernel/patches/4.19/add-wifi-injection-4.14.patch
patch -p1 < kali-nethunter-kernel/patches/4.19/fix-ath9k-naming-conflict.patch
```

# For Rom Devs

If you want to inline this kernel in your Roms then do this before building ( In kernel root directory ):

```bash
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
```

Do this Everytime you clone the repo bcz this kernel has the support for Kernel-SU and it needs to be recloned and checkout to latest stable tag.

# For Kenrel Devs

I'v made a fully automated script from scratch to the packaged kernel.

```bash
cd /path/to/kernel/source
./build.sh
```

- Template example (``kali-nethunter-project/nethunter-installer/devices/devices.cfg``)

```bash
# Xiaomi 10 for HyperOS Android 14
[umi]
author = "Yttehs"
arch = arm64
version = "v1.0"
flasher = anykernel
modules = 1
slot_device = 0
block = /dev/block/bootdevice/by-name/boot
devicenames = umi,Mi10
```

Finally, get the zip file in ``kali-nethunter-project/nethunter-installer/kernel-nethunter-YYYYMMDD_HHMMSS-umi-thirteen.zip`` .

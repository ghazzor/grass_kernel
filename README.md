
<h1 align="center">
  <br>
  <img src="https://i.ibb.co/LYYJzJC/logo.jpg" alt="Markdownify" width="2048">
  <br>
  GrassKernel
  <br>
</h1>

<h4 align="center">A custom kernel for the Exynos9611 devices.</h4>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-build">How To Build</a> •
  <a href="#how-to-flash">How To Flash</a> •
  <a href="#credits">Credits</a>
</p>

## Key Features

* Disable Samsung securities, debug drivers, etc modifications
* Checkout and rebase against Android common kernel source, Removing Samsung additions to drivers like ext4,f2fs and more
* Compiled with bleeding edge Neutron Clang 19, with full LLVM binutils, LTO (Link time optimization) and -O2  
* Import Erofs, Incremental FS, BinderFS and several backports.
* Supports DeX touchpad for corresponding OneUI ports that have DeX ported.
* Lot of debug codes/configuration Samsung added are removed.
* Added [wireguard](https://www.wireguard.com/) driver, an open-source VPN driver in-kernel
* Added [KernelSU](https://kernelsu.org/)

## Differences From Official Grass

* 4.14.187
* Uses `-O2` instead of `-O3` , cuz O3 hurts battery life and thermals
* Configurable cpu freq through defconfig
* `anxiety` is the default i/o scheduler for oneui and `zen` for aosp
* SLUB_CPU_PARTIAL is disabled (better latency less load spikes)
* Power suspend and wl blocker
* Inline Optmizations kanged from fresh kernel (`a50`)

## How To Build

You will need ubuntu, git, around 8GB RAM and bla-bla-bla...
or just fork this repo, enable workflows , do your edits and the workflow will build it for you
```bash
# Install dependencies
$ sudo apt install -y bash git make libssl-dev curl bc pkg-config m4 libtool automake autoconf

# Clone this repository
$ git clone --depth=1 https://github.com/ghazzor/grass_kernel

# Go into the repository
$ cd grass_kernel

# Install toolchain
# You could try any clang/LLVM based toolchain, however I use neutron clang
# If you are using Arch or distro with latest glibc, You may want to use antman instead.
$ bash <(curl https://gist.githubusercontent.com/roynatech2544/0feeeb35a6d1782b186990ff2a0b3657/raw/b170134a94dac3594df506716bc7b802add2724b/setup.sh)

# If you want to compile the kernel not for m21 then export DEVICE variable to a51, m31, m31s, f41
# Build the kernel
$ ./build_kernel.sh or ROM=aosp ./build_kernel.sh # (for M21, AOSP , KSU is disabled , enforcing)
$ ROM=oneui ./build_kernel.sh # (for OneUI)
$ SELINUX=p ./build_kernel.sh # (for permissive)
$ SELINUX=e ./build_kernel.sh # (for enforcing (default))
$ DEVICE=a51 ROM=aosp ./build_kernel.sh # (for A51, AOSP)
$ KSU=1 ./build_kernel.sh # (for KSU)
```

After build the image of the kernel will be in out/arch/arm64/boot/Image

## Optional Stuff

Overclocking / Underclocking CPU

```shell
# Add there to arch/arm64/configs/vendor/grass.config
# These are stock values, edit them to your needs
CONFIG_ARM_MODCLOCK=y
CONFIG_MAX_FREQ_BIG=2314000
CONFIG_MIN_FREQ_BIG=936000
CONFIG_MAX_FREQ_LITTLE=1742000
CONFIG_MIN_FREQ_LITTLE=403000
```
(minium on big cores is 728 mhz and LITTLE cores is 403mhz , setting them any lower is not possible)

## How To Flash

After a successful build, you can see the kernel_zip/Grass*.zip archive.
This is your kernel. Just flash it via TWRP or adb sideload

## Credits

- [roynatech2544](https://github.com/roynatech2544)
- [Samsung Open Source](https://opensource.samsung.com/)
- [Android Open Source Project](https://source.android.com/)
- [The Linux Kernel](https://www.kernel.org/)
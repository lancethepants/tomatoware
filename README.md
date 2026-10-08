tomatoware
==========

Tomatoware is a native development environment for routers running
[Tomato64](https://github.com/tomato64/tomato64): a GCC toolchain and the
tools around it that run on the router itself, unpacked at `/mmc` and linked
against their own bundled musl.

Targets
-------

| Target   | Runs on                              | Kernel     | CPU baseline             |
|----------|--------------------------------------|------------|--------------------------|
| `x86_64` | x86_64 (UEFI and legacy builds)      | 6.12       | x86-64                   |
| `arm64`  | every arm64 Tomato64 device          | 6.12       | Cortex-A53               |
| `arm`    | bcm53xx                              | 6.12       | Cortex-A9, soft-float    |
| `arm-ft` | FreshTomato ARM                      | 2.6.36.4   | Cortex-A9, soft-float    |

`arm-ft` is `arm` built against vanilla Linux 2.6.36.4 kernel headers, so
it runs on FreshTomato's Broadcom ARM firmware.

Building
--------

To build tomatoware use Debian 12 or 13 and run:

    apt install bc build-essential cpio file git libncurses-dev rsync unzip wget

    git clone https://github.com/lancethepants/tomatoware.git
    cd tomatoware

Then build the target for your device:

| Device                          | Command       |
|---------------------------------|---------------|
| x86_64 (UEFI and legacy builds) | `make x86_64` |
| every arm64 Tomato64 device     | `make arm64`  |
| bcm53xx                         | `make arm`    |
| FreshTomato ARM                 | `make arm-ft` |

Buildroot and all package sources are downloaded to `~/buildroot-src`. Each
target builds in its own `output/<target>` directory, so targets can be built
side by side. The resulting bundles are:

| Target   | Bundle                                                      |
|----------|-------------------------------------------------------------|
| `x86_64` | `output/x86_64/images/tomatoware-x86_64-musl-mmc.tar.xz`    |
| `arm64`  | `output/arm64/images/tomatoware-arm64-musl-mmc.tar.xz`      |
| `arm`    | `output/arm/images/tomatoware-arm-musl-mmc.tar.xz`          |
| `arm-ft` | `output/arm-ft/images/tomatoware-arm-ft-musl-mmc.tar.gz`    |

Installing
----------

On bcm53xx (`arm`) and FreshTomato (`arm-ft`), mount external storage such
as a USB disk at `/mmc` first; the bundle needs about 1 GB unpacked. Swap is
also recommended on those devices for best results.

    tar xf tomatoware-<target>-musl-mmc.tar.xz -C /mmc     # Tomato64
    tar xzf tomatoware-arm-ft-musl-mmc.tar.gz -C /mmc      # FreshTomato (arm-ft)
    . /mmc/etc/profile                                     # sets PATH etc. for this shell session
    /mmc/share/tomatoware/smoke-test.sh                    # optional: runs tests

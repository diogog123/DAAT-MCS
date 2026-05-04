# Build Instructions

## 1. Building a simple Linux guest

This directory allows you to build a linux guest to run on top of Bao. To build a simple linux image, run the following command:

```sh
make PLATFORM=<target_platform> ARCH=<target_architecture> GUEST_LOAD_ADDRESS=<guest_base_address>
``` 

The GUEST_LOAD_ADDRESS corresponds to the address defined in the ``base_addr`` field of the bao ``.config`` file

## 2. Include files in the rootfs

All the files included in the [rootfs_overlay folder](./rootfs_overlay) will be included in the ``initramfs`` of the linux guest.
If you already compiled the linux guest image, and you want to update the rootfs content, copy your files to the ``rootfs_overlay`` directory and run:

```sh
make rebuild_initramfs PLATFORM=<target_platform> ARCH=<target_architecture> GUEST_LOAD_ADDRESS=<guest_base_address>
``` 

## 3. Benchmarks and tools
Aditionally, you can include some benchmarks and tools (a set of "recipes" are available in the linux_extensions [folder](./linux_extensions/)). To build the available tools/benchmarks, run the following command:

```sh
make rebuild_initramfs \
    PLATFORM=<target_platform> \
    ARCH=<target_architecture> \
    GUEST_LOAD_ADDRESS=<guest_base_address> \
    TOOLS="<list_of_tools>" \
    BENCHMARKS="<list_of_benchmarks>"
```


ROOT_DIR := $(shell realpath .)
WRKDIR := $(ROOT_DIR)/wrkdir
BUILDROOT_ARCH := arm64
LINUX_REPO := https://github.com/torvalds/linux.git
LINUX_VERSION := v6.1
LINUX_SRC := $(WRKDIR)/linux-$(LINUX_VERSION)
BUILDROOT_REPO := https://github.com/buildroot/buildroot.git
BUILDROOT_VERSION := 2022.11
BUILDROOT_SRC := $(WRKDIR)/buildroot-$(ARCH)-$(BUILDROOT_VERSION)
BAO_BUILDROOT_DEFCFG := $(ROOT_DIR)/buildroot/$(ARCH).config
LINUX_SRC_CFG_FRAG := $(wildcard $(ROOT_DIR)/configs/base.config $(ROOT_DIR)/configs/$(ARCH).config $(ROOT_DIR)/configs/$(PLATFORM).config)
OVERLAY_DIR := $(ROOT_DIR)/rootfs_overlay

ifndef PLATFORM
 $(error Platform not defined)
endif

ifndef ARCH
 $(error Architecture not defined)
endif

# Targets
.PHONY: all setup buildroot linux linux_extensions dtb initramfs bao_guest_static_loader clean

all:  buildroot linux linux_extensions dtb initramfs bao_guest_static_loader

rebuild_initramfs: linux_extensions initramfs bao_guest_static_loader

setup:
	mkdir -p $(WRKDIR)

buildroot: setup
	git clone $(BUILDROOT_REPO) $(BUILDROOT_SRC) --depth 1 --branch $(BUILDROOT_VERSION)
	cd $(BUILDROOT_SRC) && \
	make defconfig BR2_DEFCONFIG=$(BAO_BUILDROOT_DEFCFG) && \
	make
	cp $(BUILDROOT_SRC)/output/images/rootfs.cpio $(WRKDIR)/rootfs.cpio

linux: setup
	@if [ ! -d "$(LINUX_SRC)" ]; then \
		git clone $(LINUX_REPO) $(LINUX_SRC) --depth 1 --branch $(LINUX_VERSION) && \
		cd $(LINUX_SRC) && \
		git apply $(ROOT_DIR)/patches/$(LINUX_VERSION)/*.patch && \
		make defconfig \
			ARCH=$(BUILDROOT_ARCH) \
			CROSS_COMPILE=$(BUILDROOT_SRC)/output/host/bin/$(ARCH)-linux-; \
	fi

	cd $(LINUX_SRC) && \
	echo "CONFIG_BAO_HYPERCALLS=y" >> .config && \
	make ARCH=$(BUILDROOT_ARCH) \
		CROSS_COMPILE=$(BUILDROOT_SRC)/output/host/bin/$(ARCH)-linux- \
		-j$$(nproc) Image

	cp $(LINUX_SRC)/arch/$(BUILDROOT_ARCH)/boot/Image \
		$(WRKDIR)/Image-$(PLATFORM)

linux_extensions: setup
	@if [ -z "$(BENCHMARK)" ] && [ -z "$(TOOLS)" ]; then \
		echo "Skipping linux extensions: BENCHMARK and TOOLS are not defined."; \
	else \
		echo "Running linux extensions with BENCHMARK=$(BENCHMARK) and TOOLS=$(TOOLS)"; \
		$(MAKE) -C $(ROOT_DIR)/linux_extensions \
			BENCHMARK=$(BENCHMARK) \
			TOOLS=$(TOOLS) \
			ROOTFS_OVERLAY_DIR=$(OVERLAY_DIR) \
			BUILDROOT_DIR=$(BUILDROOT_SRC) \
			BAO_BUILDROOT_DEFCFG=$(BAO_BUILDROOT_DEFCFG) \
			LINUX_KERNEL_DIR=$(LINUX_SRC) \
			CROSS_COMPILE=$(BUILDROOT_SRC)/output/host/bin/$(ARCH)-linux- \
			ARCH=$(ARCH); \
	fi
	

dtb: setup
	dtc $(ROOT_DIR)/devicetrees/$(PLATFORM)/linux.dts -o $(WRKDIR)/linux.dtb

bao_guest_static_loader: setup
	make -C $(ROOT_DIR)/bao-guest-static-loader clean
	rm -f $(WRKDIR)/linux.elf $(WRKDIR)/linux.bin
	make -C $(ROOT_DIR)/bao-guest-static-loader \
		ARCH=$(ARCH) \
		IMAGE=$(WRKDIR)/Image-$(PLATFORM) \
		DTB=$(WRKDIR)/linux.dtb \
		TARGET=$(WRKDIR)/linux \
		INITRAMFS=$(WRKDIR)/new_rootfs.cpio

initramfs: setup
	cp $(BUILDROOT_SRC)/output/images/rootfs.cpio $(WRKDIR)/rootfs.cpio
	mkdir -p $(WRKDIR)/rootfs
	cd $(WRKDIR)/rootfs && \
		cpio -idm < ../rootfs.cpio || true
	cp -r $(OVERLAY_DIR)/* $(WRKDIR)/rootfs
	cd $(WRKDIR)/rootfs && \
		find . | cpio -o -H newc --owner root:root > ../new_rootfs.cpio
	sudo rm -r $(WRKDIR)/rootfs

clean:
	rm -rf $(WRKDIR)

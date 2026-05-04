LINUX_KERNEL_DIR ?=
CROSS_COMPILE ?=
ARCH ?=
OUT_DIR ?=

.PHONY: all
all: build move_to_out_dir

.PHONY: check_vars
check_vars:
	@if [ -z "$(LINUX_KERNEL_DIR)" ]; then \
		echo "LINUX_KERNEL_DIR is not defined. Please specify LINUX_KERNEL_DIR=<path_to_kernel>"; \
		exit 1; \
	fi
	@if [ -z "$(ROOTFS_OVERLAY_DIR)" ]; then \
		echo "OUT_DIR is not defined. Please specify OUT_DIR=<output_directory>"; \
		exit 1; \
	fi
	@if [ -z "$(CROSS_COMPILE)" ]; then \
		echo "CROSS_COMPILE is not defined. Please specify CROSS_COMPILE=<cross_compiler>"; \
		exit 1; \
	fi
	@if [ -z "$(ARCH)" ]; then \
		echo "ARCH is not defined. Please specify ARCH=<architecture>"; \
		exit 1; \
	fi

.PHONY: build
build:
	@echo "Building perf with LINUX_KERNEL_DIR=$(LINUX_KERNEL_DIR) ..."
	@BUILD_ARCH=$(BUILD_ARCH); \
	if [ "$(ARCH)" = "aarch64" ]; then \
		BUILD_ARCH="arm64"; \
	elif [ "$(ARCH)" = "riscv" ]; then \
		BUILD_ARCH="riscv"; \
	else \
		echo "Unsupported architecture: $(ARCH)"; \
		exit 1; \
	fi; \
	$(MAKE) -C $(LINUX_KERNEL_DIR)/tools/perf ARCH=$$BUILD_ARCH CROSS_COMPILE=$(CROSS_COMPILE)

.PHONY: move_to_out_dir
move_to_out_dir:
	@echo "Moving built artifacts to $(ROOTFS_OVERLAY_DIR)..."
	mkdir -p $(ROOTFS_OVERLAY_DIR)/bin
	cp $(LINUX_KERNEL_DIR)/tools/perf/perf $(ROOTFS_OVERLAY_DIR)/bin/
	

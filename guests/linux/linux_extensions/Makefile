BENCHMARK ?=
TOOLS ?=
OUT_DIR ?=
BUILDROOT_DIR ?=
LINUX_KERNEL_DIR ?=

ROOT_DIR := $(realpath .)
BENCHMARKS_DIR := $(ROOT_DIR)/benchmarks
TOOLS_DIR := $(ROOT_DIR)/tools

.PHONY: all
all: check_vars
	@if [ ! -z "$(TOOLS)" ]; then \
		echo "Building tool $(TOOLS)..."; \
		$(MAKE) build_tools; \
	fi
	@if [ ! -z "$(BENCHMARK)" ]; then \
		echo "Building benchmark $(BENCHMARK)..."; \
		$(MAKE) build_benchmark; \
	fi
	# $(MAKE) move_to_out_dir

.PHONY: check_vars
check_vars:
ifeq ($(BENCHMARK)$(TOOLS),)
	$(error BENCHMARK and TOOLS are not defined. Please specify at least one: \
	BENCHMARK=<benchmark_name> and/or TOOLS=<tool_name>)
endif

ifndef ROOTFS_OVERLAY_DIR
	$(error ROOTFS_OVERLAY_DIR is not defined. Please specify ROOTFS_OVERLAY_DIR=<output_directory>)
endif

.PHONY: build_benchmark
build_benchmark:
	@echo "Building benchmark $(BENCHMARK)..."
	$(MAKE) -C $(BENCHMARKS_DIR)/$(BENCHMARK) \
				ROOTFS_OVERLAY_DIR=$(ROOTFS_OVERLAY_DIR) \
				BUILDROOT_DIR=$(BUILDROOT_DIR) \
				BENCHMARKS="$(BENCHMARK)"


.PHONY: build_tools
build_tools:
	@echo "Building tools.."
	$(MAKE) -C $(ROOT_DIR)/tools \
				BUILDROOT_DIR=$(BUILDROOT_DIR) \
				BR_DEFCFG=$(BAO_BUILDROOT_DEFCFG) \
				LINUX_KERNEL_DIR=$(LINUX_KERNEL_DIR) \
				ARCH=$(ARCH) \
				TOOLS="$(TOOLS)" \
				ROOTFS_OVERLAY_DIR=$(ROOTFS_OVERLAY_DIR)

.PHONY: clean
clean:
	@echo "Cleaning build directories..."
	$(MAKE) -C $(BENCHMARKS_DIR)/$(BENCHMARK) clean
	$(MAKE) -C $(TOOLS_DIR)/$(TOOLS) clean
	@echo "Cleaning output directory..."
	rm -rf $(OUT_DIR)

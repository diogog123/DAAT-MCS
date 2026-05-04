# SUBDIRS = basicmath bitcount qsort susan

# .PHONY: subdirs $(SUBDIRS)

# subdirs: $(SUBDIRS)

# $(SUBDIRS):
# 	$(MAKE) -C $@
CROSS_COMPILE ?=
ROOT_DIR := $(realpath .)
OUT_DIR := $(ROOTFS_OVERLAY_DIR)/root/benchmarks/MiBench
SUITES := automotive
benchmarks := $(foreach suite,$(SUITES),$(wildcard $(suite)/*/Makefile) $(wildcard $(suite)/*/src/Makefile))
benchmarks := $(dir $(benchmarks))
export

.PHONY: all
all: check_vars build move_to_out_dir
# all: $(benchmarks) update_rootfs

.PHONY: check_vars
check_vars:
	@if [ -z "$(ROOTFS_OVERLAY_DIR)" ]; then \
		echo "OUT_DIR is not defined. Please specify OUT_DIR=<output_directory>"; \
		exit 1; \
	fi
	@if [ -z "$(ARCH)" ]; then \
		echo "ARCH is not defined. Please specify ARCH=<architecture>"; \
		exit 1; \
	fi

.PHONY: build
build: $(benchmarks)
	@echo "Building benchmarks in $(SUITES)..."

$(benchmarks):
	@echo "Building benchmark: $@"
	@$(MAKE) -C $(ROOT_DIR)/$@ $(MAKECMDGOALS) OUT_DIR=$(OUT_DIR)/$@ CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH)

install: | $(INSTALL_DIR)
	cp ./runme.sh $(INSTALL_DIR)

$(INSTALL_DIR):
	mkdir -p $(INSTALL_DIR)/$@

move_to_out_dir:
	@echo "Moving built artifacts to $(OUT_DIR)..."
	cp ./run_all.sh $(OUT_DIR)/run_all.sh

.PHONY: all $(benchmarks)



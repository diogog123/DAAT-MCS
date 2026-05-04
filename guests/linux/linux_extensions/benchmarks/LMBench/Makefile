# ToDo: makefile para copiar o run.sh para o rootfs
# no run.sh adicionar tags de start e end

ROOT_DIR := $(realpath .)
OUT_DIR := $(ROOTFS_OVERLAY_DIR)/root/benchmarks/LMBench

.PHONY: all
all: check_vars move_to_out_dir

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

move_to_out_dir:
	@echo "Moving artifacts to $(OUT_DIR)..."
	mkdir -p $(OUT_DIR)
	cp ./run_all.sh $(OUT_DIR)/run_all.sh
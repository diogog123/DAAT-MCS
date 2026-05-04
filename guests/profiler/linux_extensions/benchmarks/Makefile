BUILDROOT_DIR ?=
ARCH ?=
TOOLS_LIST := $(BENCHMARK)

.PHONY: all
all: check_vars build_benchmarks

.PHONY: check_vars
check_vars:
	@if [ -z "$(BUILDROOT_DIR)" ]; then \
		echo "BUILDROOT_DIR is not defined. Please specify BUILDROOT_DIR=<path_to_buildroot>"; \
		exit 1; \
	fi
	@if [ -z "$(ARCH)" ]; then \
		echo "ARCH is not defined. Please specify ARCH=<architecture>"; \
		exit 1; \
	fi
	@if [ -z "$(BENCHMARK)" ]; then \
		echo "BENCHMARK is not defined. Please specify BENCHMARK=<benchmark_name>"; \
		exit 1; \
	fi

.PHONY: build_benchmarks
	@echo "Building benchmarks"
	@for benchmark in $(BENCHMARKS_LIST); do \
		echo "Building $$benchmark"; \
		$(MAKE) -C 	$$benchmark \
					CROSS_COMPILE=$(BUILDROOT_DIR)/output/host/bin/$(ARCH)-linux-
					ARCH=$(ARCH) \
					BENCHMARKS="$(BENCHMARK)"
	done
BUILDROOT_DIR ?=
LINUX_KERNEL_DIR ?=
ARCH ?=
TOOL_LIST := $(TOOLS)

.PHONY: all
all: check_vars build_tools

.PHONY: check_vars
check_vars:
	@if [ -z "$(BUILDROOT_DIR)" ]; then \
		echo "BUILDROOT_DIR is not defined. Please specify BUILDROOT_DIR=<path_to_buildroot>"; \
		exit 1; \
	fi
	@if [ -z "$(LINUX_KERNEL_DIR)" ]; then \
		echo "LINUX_KERNEL_DIR is not defined. Please specify LINUX_KERNEL_DIR=<path_to_kernel>"; \
		exit 1; \
	fi
	@if [ -z "$(ARCH)" ]; then \
		echo "ARCH is not defined. Please specify ARCH=<architecture>"; \
		exit 1; \
	fi
	@if [ -z "$(TOOLS)" ]; then \
		echo "TOOLS is not defined. Please specify TOOLS=<list_of_tools>"; \
		exit 1; \
	fi
	@if [ -z "$(BR_DEFCFG)" ]; then \
		echo "BR_DEFCFG is not defined. Please specify BR_DEFCFG=<path_to_buildroot_defconfig>"; \
		exit 1; \
	fi

.PHONY: compile_buildroot
compile_buildroot:
	@echo "Compiling Buildroot with configurations for tools:"

	@if [ -f "$(BR_DEFCFG)" ]; then \
		cat $(BR_DEFCFG) > .config; \
		echo "Successfully loaded $(BR_DEFCFG)"; \
	else \
		echo "Error: BR_DEFCFG not found!"; \
		exit 1; \
	fi

	@for tool in $(TOOL_LIST); do \
		echo "Configuring $$tool"; \
		if [ -f "$$tool/buildroot/$(ARCH).config" ]; then \
			cat .config $$tool/buildroot/$(ARCH).config > .config.tmp; \
			mv .config.tmp .config; \
		else \
			echo "Warning: Configuration file for $$tool not found."; \
		fi \
	done

	@echo "Building Buildroot..."
	@make -C $(BUILDROOT_DIR) clean
	@cp .config $(BR_DEFCFG)
	@echo "------------------------------------------------------------"
	@echo "Copying .config to $(BR_DEFCFG)"
	@echo "------------------------------------------------------------"
	
	@echo "------------------------------------------------------------1111"
	@make -C $(BUILDROOT_DIR) defconfig BR2_DEFCONFIG=$(BR_DEFCFG)
	@make -C $(BUILDROOT_DIR)

.PHONY: build_tools
build_tools: compile_buildroot
	@echo "Building tools..."
	@for tool in $(TOOL_LIST); do \
		$(MAKE) -C $$tool CROSS_COMPILE=$(BUILDROOT_DIR)/output/host/bin/$(ARCH)-linux- \
				LINUX_KERNEL_DIR=$(LINUX_KERNEL_DIR) ARCH=$(ARCH); \
	done

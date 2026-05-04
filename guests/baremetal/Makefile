# SPDX-License-Identifier: GPL-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

NAME := baremetal
ROOT_DIR := $(realpath .)

APP ?= cache_stressor
WORKLOAD ?= constant_stress
PLATFORM ?= qemu-aarch64-virt

# Keep different configurations in different output trees
BUILD_DIR := $(ROOT_DIR)/build/$(PLATFORM)/$(APP)/$(WORKLOAD)

# list of supported baremetal apps
#
# - [APP] cache_stressor:
#   - [WORKLOAD] constant_stress: a simple app that performs a constant amount of work in an infinite loop
#   - [WORKLOAD] intermittent_stress: an app that performs a constant amount of work in bursts, with idle periods in between
#
# - [APP] embench: a collection of benchmarks from the Embench suite
#   - [WORKLOAD] aha-mont64
#   - [WORKLOAD] crc32
#   - [WORKLOAD] cubic
#   - [WORKLOAD] edn
#   - [WORKLOAD] huffbench
#   - [WORKLOAD] matmult-int
#   - [WORKLOAD] md5sum
#   - [WORKLOAD] minver
#   - [WORKLOAD] nbody
#   - [WORKLOAD] nettle-aes
#   - [WORKLOAD] nettle-sha256
#   - [WORKLOAD] nsichneu
#   - [WORKLOAD] picojpeg
#   - [WORKLOAD] primecount
#   - [WORKLOAD] qrduino
#   - [WORKLOAD] sglib-combined
#   - [WORKLOAD] slre
#   - [WORKLOAD] st
#   - [WORKLOAD] statemate
#   - [WORKLOAD] support
#   - [WORKLOAD] tarfind
#   - [WORKLOAD] ud
#   - [WORKLOAD] wikisort

bmrt_dir := $(ROOT_DIR)/src/baremetal-runtime
include $(bmrt_dir)/setup.mk

ifeq ($(APP),cache_stressor)
bmg_dir := $(ROOT_DIR)/src/baremetal-app/$(APP)/$(WORKLOAD)
include $(bmg_dir)/setup.mk
endif

ifeq ($(APP),embench)
bmg_dir := $(ROOT_DIR)/src/baremetal-app/$(APP)
include $(bmg_dir)/setup.mk
endif

# Include the final baremetal-runtime build
include $(bmrt_dir)/build.mk

# Keep only extra top-level targets here; do not redefine "clean"
.PHONY: distclean print-config

distclean:
	$(RM) -r $(ROOT_DIR)/build

print-config:
	@echo "ROOT_DIR   = $(ROOT_DIR)"
	@echo "PLATFORM   = $(PLATFORM)"
	@echo "APP        = $(APP)"
	@echo "WORKLOAD   = $(WORKLOAD)"
	@echo "BUILD_DIR  = $(BUILD_DIR)"
	@echo "bmrt_dir   = $(bmrt_dir)"
	@echo "bmg_dir    = $(bmg_dir)"
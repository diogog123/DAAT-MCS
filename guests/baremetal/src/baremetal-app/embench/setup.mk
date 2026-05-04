EMBENCH_DIR := $(bmg_dir)
EMBENCH_SUPPORT_DIR := $(EMBENCH_DIR)/support
BENCH ?= $(WORKLOAD)
BENCH_DIR := $(EMBENCH_DIR)/$(BENCH)

ifeq ($(wildcard $(BENCH_DIR)),)
$(error unsupported embench workload '$(BENCH)' (set WORKLOAD=<name> or BENCH=<name>))
endif

SRC_DIRS += $(EMBENCH_SUPPORT_DIR) $(BENCH_DIR)
INC_DIRS += $(EMBENCH_SUPPORT_DIR) $(BENCH_DIR)

C_SRC += $(wildcard $(EMBENCH_SUPPORT_DIR)/*.c)
C_SRC += $(wildcard $(BENCH_DIR)/*.c)

CPPFLAGS += -DBENCH_$(shell echo $(BENCH) | tr '[:lower:]-' '[:upper:]_')

include $(bmg_dir)/sources.mk
C_SRC+= $(addprefix $(bmg_dir)/, $(src_c_srcs))

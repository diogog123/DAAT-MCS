## SPDX-License-Identifier: Apache-2.0
## Copyright (c) Bao Project and Contributors. All rights reserved.

SHELL := bash

# Project name
PROJECT_NAME := profiling_tcp

# Variables
CROSS_COMPILE ?=
CFLAGS += -Wall -Wextra -static
CC = $(CROSS_COMPILE)gcc

# Directories and source files
SRC_DIR := src
INC_DIR := include
BUILD_DIR := build

C_SRC := $(wildcard $(SRC_DIR)/*.c)
OBJ := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SRC))
INCLUDES := -I$(INC_DIR)

# Output binaries
SERVER_TARGET := $(BUILD_DIR)/server.out
CLIENT_TARGET := $(BUILD_DIR)/client.out

# Create build directory if it does not exist
$(shell mkdir -p $(BUILD_DIR))

# Default target: build both server and client
all: server client

# Compile the server
server: $(SERVER_TARGET)

# Compile the client
client: $(CLIENT_TARGET)

# Rule to create the server executable
$(SERVER_TARGET): $(BUILD_DIR)/server.o $(BUILD_DIR)/profiling_tcp.o
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $^

# Rule to create the client executable
$(CLIENT_TARGET): $(BUILD_DIR)/client.o $(BUILD_DIR)/profiling_tcp.o $(BUILD_DIR)/tracer.o
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $^

# Rule to compile each source file into an object file
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Clean up
clean:
	rm -rf $(BUILD_DIR)

# Phony targets
.PHONY: all clean server client

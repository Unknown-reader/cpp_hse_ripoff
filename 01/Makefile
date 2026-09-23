SHELL := /bin/bash

# Makefile одной домашней работы NN/.
# Самодостаточный: при создании новой работы скопируйте этот файл в её каталог.

NAME := $(notdir $(CURDIR))
ROOT := $(abspath ..)

CXX ?= g++
AR ?= ar
GCOVR ?= gcovr

CPPFLAGS += -Iinclude
CXXFLAGS ?= -std=c++20 -Wall -Wextra -Wpedantic -Wshadow \
	-Wconversion -Wsign-conversion -g
GTEST_LDLIBS ?= -lgtest -lgtest_main -pthread

ifeq ($(WERROR),1)
  CXXFLAGS += -Werror
endif
ifeq ($(SAN),1)
  CXXFLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer
  LDFLAGS += -fsanitize=address,undefined
endif
ifeq ($(COV),1)
  CXXFLAGS += --coverage -O0
  LDFLAGS += --coverage
endif

BUILD_DIR ?= $(ROOT)/build/$(NAME)
ASAN_BUILD_DIR := $(ROOT)/build-asan/$(NAME)
COV_BUILD_DIR := $(ROOT)/build-cov/$(NAME)
COVERAGE_DIR ?= coverage

LIB_SRCS := $(wildcard src/*.cpp)
TEST_SRCS := $(wildcard tests/*.cpp)
LIB_OBJS := $(patsubst src/%.cpp,$(BUILD_DIR)/src/%.o,$(LIB_SRCS))
TEST_OBJS := $(patsubst tests/%.cpp,$(BUILD_DIR)/tests/%.o,$(TEST_SRCS))
LIB := $(BUILD_DIR)/libhw$(NAME).a
TEST_BIN := $(BUILD_DIR)/hw$(NAME)_tests

ifeq ($(strip $(TEST_SRCS)),)
  ALL_TARGETS := $(LIB)
else
  ALL_TARGETS := $(LIB) $(TEST_BIN)
endif

.DEFAULT_GOAL := build

.PHONY: build test sanitize coverage clean lint help

build: $(ALL_TARGETS)

$(LIB): $(LIB_OBJS)
	@mkdir -p $(dir $@)
	$(AR) rcs $@ $^

$(TEST_BIN): $(TEST_OBJS) $(LIB)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(TEST_OBJS) $(LIB) $(GTEST_LDLIBS)

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $(abspath $<) -o $@

-include $(LIB_OBJS:.o=.d) $(TEST_OBJS:.o=.d)

test: $(TEST_BIN)
	$(TEST_BIN)

sanitize:
	@$(MAKE) --no-print-directory SAN=1 BUILD_DIR=$(ASAN_BUILD_DIR) \
		$(ASAN_BUILD_DIR)/hw$(NAME)_tests
	@ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=print_stacktrace=1 \
		$(ASAN_BUILD_DIR)/hw$(NAME)_tests

coverage:
	@$(MAKE) --no-print-directory COV=1 BUILD_DIR=$(COV_BUILD_DIR) \
		$(COV_BUILD_DIR)/hw$(NAME)_tests
	@$(COV_BUILD_DIR)/hw$(NAME)_tests
	@mkdir -p $(COVERAGE_DIR)
	@$(GCOVR) --root $(ROOT) --gcov-object-directory $(COV_BUILD_DIR) \
		--filter '$(NAME)/.*' \
		--exclude '.*/(tests|third_party)/.*' \
		--exclude-unreachable-branches --exclude-throw-branches \
		--cobertura-pretty --cobertura $(COVERAGE_DIR)/coverage.xml \
		--html-details $(COVERAGE_DIR)/index.html \
		--txt $(COVERAGE_DIR)/coverage.txt
	@echo "Покрытие $(NAME): $(COVERAGE_DIR)/index.html"

lint:
	@cpplint --recursive --quiet --filter=-legal/copyright --root=include .
	@for f in $(LIB_SRCS) $(TEST_SRCS); do \
		echo "clang-tidy $$f"; \
		clang-tidy -quiet "$$f" -- -std=c++20 -Iinclude || exit 1; \
	done
	@cppcheck --enable=all --inconclusive --error-exitcode=1 --std=c++20 \
		--suppress=missingIncludeSystem --suppress=unusedFunction \
		--suppress=unmatchedSuppression -Iinclude src include

clean:
	@rm -rf $(ROOT)/build/$(NAME) $(ROOT)/build-asan/$(NAME) \
		$(ROOT)/build-cov/$(NAME) $(COVERAGE_DIR)

help:
	@echo "Работа $(NAME):"
	@echo "  make build|test|sanitize|coverage|lint|clean"

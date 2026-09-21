SHELL := /bin/bash

CMAKE ?= cmake
CTEST ?= ctest
CC ?= clang
CXX ?= clang++
CLANG_FORMAT ?= clang-format
CPPLINT ?= cpplint
GCOVR ?= gcovr
LLVM_COV ?= $(shell command -v llvm-cov || command -v llvm-cov-18 \
	|| command -v llvm-cov-19 || echo llvm-cov)
JOBS ?= $(shell nproc 2>/dev/null || echo 2)

BUILD_TYPE ?= Debug
BUILD_DIR ?= build
BUILD_ASAN_DIR ?= build-asan
BUILD_COV_DIR ?= build-cov
COVERAGE_DIR ?= coverage
CMAKE_FLAGS ?=

HW ?=
ARGS ?=

empty :=
space := $(empty) $(empty)

HW_DIRS := $(sort $(notdir $(wildcard [0-9][0-9])))
HW_DIRS_REGEX := $(subst $(space),|,$(HW_DIRS))

HW_LIB := hw$(HW)
HW_APP := $(if $(wildcard $(HW)/app/main.cpp),hw$(HW)_app)
HW_TESTS := $(if $(wildcard $(HW)/tests),hw$(HW)_tests)
HW_TARGETS := $(HW_LIB) $(HW_APP) $(HW_TESTS)

HW_FILTER := $(if $(HW),-L hw$(HW))
TIDY_FILES := $(if $(HW),$(CURDIR)/$(HW)/.*,$(CURDIR)/($(HW_DIRS_REGEX))/.*)

HW_SCOPED_DIRS := $(if $(HW),$(HW),$(HW_DIRS))
CPPCHECK_SOURCES := $(shell find $(HW_SCOPED_DIRS) -type f \
	\( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \) \
	-not -path '*/tests/*' 2>/dev/null | sort)
CPPCHECK_INCLUDES := $(foreach d,$(HW_SCOPED_DIRS),-I$(d)/include)

FORMAT_SOURCES := $(shell find . -type d \
	\( -name .git -o -name .cache -o -name build -o -name 'build-*' \
	   -o -name coverage -o -name third_party \) -prune -o \
	-type f \( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \) -print | sort)

.DEFAULT_GOAL := help

.PHONY: help configure build test run sanitize coverage lint lint-style \
	lint-tidy lint-cppcheck format format-check new clean

help:
	@echo "Доступные команды (добавляйте HW=NN, чтобы работать с одной работой):"
	@echo ""
	@echo "  make configure            Настроить CMake (BUILD_DIR=$(BUILD_DIR))"
	@echo "  make build   [HW=NN]      Собрать всё или только работу NN"
	@echo "  make test    [HW=NN]      Собрать и прогнать тесты"
	@echo "  make run      HW=NN       Собрать и запустить приложение работы NN"
	@echo "  make sanitize [HW=NN]     Собрать и прогнать тесты под ASan/UBSan"
	@echo "  make coverage [HW=NN]     Собрать, прогнать тесты и собрать покрытие"
	@echo "  make lint     [HW=NN]     cpplint + clang-tidy + cppcheck"
	@echo "  make lint-style [HW=NN]   Только cpplint (Google C++ Style)"
	@echo "  make format   [HW=NN]     Отформатировать clang-format"
	@echo "  make format-check [HW=NN] Проверить форматирование (как в CI)"
	@echo "  make new       HW=NN      Создать каркас новой работы"
	@echo "  make clean                Удалить каталоги сборки и отчёт покрытия"
	@echo ""
	@echo "Переменные: BUILD_TYPE=$(BUILD_TYPE) JOBS=$(JOBS) ARGS='...'"
	@echo "Обнаруженные работы: $(if $(HW_DIRS),$(HW_DIRS),нет)"

configure:
	@$(CMAKE) -S . -B $(BUILD_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DCMAKE_C_COMPILER=$(CC) -DCMAKE_CXX_COMPILER=$(CXX) $(CMAKE_FLAGS)

build: configure
	@$(CMAKE) --build $(BUILD_DIR) $(if $(HW),--target $(HW_TARGETS)) --parallel $(JOBS)

test: build
	@$(CTEST) --test-dir $(BUILD_DIR) $(HW_FILTER) --output-on-failure

run: build
	@test -n "$(HW)" || { echo "Укажите работу: make run HW=01"; exit 1; }
	@test -x "$(BUILD_DIR)/$(HW)/hw$(HW)_app" || { \
		echo "Для работы $(HW) нет приложения ($(BUILD_DIR)/$(HW)/hw$(HW)_app)."; \
		exit 1; }
	@$(BUILD_DIR)/$(HW)/hw$(HW)_app $(ARGS)

sanitize:
	@$(CMAKE) -S . -B $(BUILD_ASAN_DIR) -DCMAKE_BUILD_TYPE=Debug \
		-DCMAKE_C_COMPILER=$(CC) -DCMAKE_CXX_COMPILER=$(CXX) \
		-DENABLE_SANITIZERS=ON $(CMAKE_FLAGS)
	@$(CMAKE) --build $(BUILD_ASAN_DIR) $(if $(HW),--target $(HW_TARGETS)) \
		--parallel $(JOBS)
	@ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=print_stacktrace=1 \
		$(CTEST) --test-dir $(BUILD_ASAN_DIR) $(HW_FILTER) --output-on-failure

coverage:
	@$(CMAKE) -S . -B $(BUILD_COV_DIR) -DCMAKE_BUILD_TYPE=Debug \
		-DENABLE_COVERAGE=ON $(CMAKE_FLAGS)
	@$(CMAKE) --build $(BUILD_COV_DIR) --parallel $(JOBS)
	@$(CTEST) --test-dir $(BUILD_COV_DIR) $(HW_FILTER) --output-on-failure
	@mkdir -p $(COVERAGE_DIR)
	@$(GCOVR) --root . --gcov-object-directory $(BUILD_COV_DIR) \
		$(if $(HW),--filter '$(HW)/.*',) \
		--exclude '(^|/)build[^/]*/.*' \
		--exclude '.*/(_deps|tests|app|third_party)/.*' \
		--exclude-unreachable-branches --exclude-throw-branches \
		--cobertura-pretty --cobertura $(COVERAGE_DIR)/coverage.xml \
		--html-details $(COVERAGE_DIR)/index.html \
		--txt $(COVERAGE_DIR)/coverage.txt
	@cat $(COVERAGE_DIR)/coverage.txt
	@echo "Покрытие: $(COVERAGE_DIR)/index.html и $(COVERAGE_DIR)/coverage.xml"

lint: lint-style lint-tidy lint-cppcheck

lint-style:
	@test -n "$(HW_SCOPED_DIRS)" || { echo "Нет работ для проверки."; exit 0; }
	@for dir in $(HW_SCOPED_DIRS); do \
		$(CPPLINT) --recursive --quiet --filter=-legal/copyright \
			--root="$$dir/include" "$$dir" || exit 1; \
	done

lint-tidy: configure
	@run-clang-tidy -p $(BUILD_DIR) -quiet '$(TIDY_FILES)'

lint-cppcheck:
	@test -n "$(CPPCHECK_SOURCES)" || { echo "Нет файлов для cppcheck."; exit 0; }
	@cppcheck --enable=all --inconclusive --error-exitcode=1 --std=c++20 \
		--suppress=missingIncludeSystem --suppress=unusedFunction \
		--suppress=unmatchedSuppression \
		$(CPPCHECK_INCLUDES) $(CPPCHECK_SOURCES)

format:
	@$(CLANG_FORMAT) -i $(FORMAT_SOURCES)
	@echo "Отформатировано файлов: $(words $(FORMAT_SOURCES))"

format-check:
	@$(CLANG_FORMAT) --dry-run --Werror $(FORMAT_SOURCES)
	@echo "Форматирование соответствует .clang-format."

new:
	@test -n "$(HW)" || { echo "Использование: make new HW=09"; exit 1; }
	@bash scripts/new_hw.sh $(HW)

clean:
	@rm -rf $(BUILD_DIR) $(BUILD_ASAN_DIR) $(BUILD_COV_DIR) $(COVERAGE_DIR)
	@echo "Каталоги сборки и отчёт покрытия удалены."

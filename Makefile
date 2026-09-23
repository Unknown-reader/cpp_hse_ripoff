SHELL := /bin/bash

ROOT := $(CURDIR)
HW_DIRS := $(sort $(notdir $(wildcard [0-9][0-9])))
HW ?=

ifeq ($(HW),)
  DIRS := $(HW_DIRS)
else
  DIRS := $(HW)
endif

CLANG_FORMAT ?= clang-format
GCOVR ?= gcovr
COVERAGE_DIR ?= coverage

FORMAT_SOURCES := $(shell find . -type d \
	\( -name .git -o -name 'build*' -o -name coverage -o -name third_party \) \
	-prune -o -type f \( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \) -print \
	| sort)

.DEFAULT_GOAL := help

.PHONY: help build test sanitize coverage lint lint-style lint-tidy \
	lint-cppcheck format format-check new clean

help:
	@echo "Домашние работы (укажите HW=NN, чтобы работать с одной):"
	@echo ""
	@echo "  make build   [HW=NN]      Собрать (все работы или одну)"
	@echo "  make test    [HW=NN]      Собрать и прогнать тесты"
	@echo "  make sanitize [HW=NN]     Тесты под ASan/UBSan"
	@echo "  make coverage [HW=NN]     Тесты + отчёт о покрытии"
	@echo "  make lint     [HW=NN]     cpplint + clang-tidy + cppcheck"
	@echo "  make lint-style [HW=NN]   Только cpplint (Google C++ Style)"
	@echo "  make format   [HW=NN]     Отформатировать clang-format"
	@echo "  make format-check [HW=NN] Проверить форматирование (как в CI)"
	@echo "  make new       HW=NN      Создать каркас новой работы"
	@echo "  make clean                Удалить каталоги сборки и отчёт покрытия"
	@echo ""
	@echo "Обнаруженные работы: $(if $(HW_DIRS),$(HW_DIRS),нет)"

build test sanitize lint-style lint-tidy lint-cppcheck:
	@for d in $(DIRS); do \
		$(MAKE) --no-print-directory -C $$d $@ || exit 1; \
	done

coverage:
	@for d in $(DIRS); do \
		$(MAKE) --no-print-directory -C $$d coverage || exit 1; \
	done
	@mkdir -p $(COVERAGE_DIR)
	@$(GCOVR) --root . --gcov-object-directory build-cov \
		$(if $(HW),--filter '$(HW)/.*',) \
		--exclude '(^|/)build[^/]*/.*' \
		--exclude '.*/(tests|third_party)/.*' \
		--exclude-unreachable-branches --exclude-throw-branches \
		--cobertura-pretty --cobertura $(COVERAGE_DIR)/coverage.xml \
		--html-details $(COVERAGE_DIR)/index.html \
		--txt $(COVERAGE_DIR)/coverage.txt
	@cat $(COVERAGE_DIR)/coverage.txt
	@echo "Покрытие: $(COVERAGE_DIR)/index.html и $(COVERAGE_DIR)/coverage.xml"

lint: lint-style lint-tidy lint-cppcheck

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
	@rm -rf build build-asan build-cov $(COVERAGE_DIR)
	@echo "Каталоги сборки и отчёт покрытия удалены."

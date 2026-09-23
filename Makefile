SHELL := /bin/bash

# Корневой Makefile: запускает цели по всем работам из списка HWS.
# Добавляя новую работу NN/, допишите ее номер в HWS.

HWS := 01
HW ?=

ifeq ($(HW),)
  DIRS := $(HWS)
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

.PHONY: help build test sanitize coverage lint \
	lint-cppcheck format format-check clean

help:
	@echo "Домашние работы (укажите HW=NN, чтобы работать с одной):"
	@echo ""
	@echo "  make build   [HW=NN]      Собрать (все работы или одну)"
	@echo "  make test    [HW=NN]      Собрать и прогнать тесты"
	@echo "  make sanitize [HW=NN]     Тесты под ASan/UBSan"
	@echo "  make coverage [HW=NN]     Тесты + отчет о покрытии"
	@echo "  make lint     [HW=NN]     cpplint + clang-tidy + cppcheck"
	@echo "  make format              Отформатировать clang-format"
	@echo "  make format-check        Проверить форматирование (как в CI)"
	@echo "  make clean                Удалить каталоги сборки и отчет покрытия"
	@echo ""
	@echo "Работы: $(HWS)"

build test sanitize:
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
	@echo "Сводное покрытие: $(COVERAGE_DIR)/index.html"

lint:
	@for d in $(DIRS); do \
		$(MAKE) --no-print-directory -C $$d lint || exit 1; \
	done
	@echo "Линт завершен."

format:
	@$(CLANG_FORMAT) -i $(FORMAT_SOURCES)
	@echo "Отформатировано файлов: $(words $(FORMAT_SOURCES))"

format-check:
	@$(CLANG_FORMAT) --dry-run --Werror $(FORMAT_SOURCES)
	@echo "Форматирование соответствует .clang-format."

clean:
	@for d in $(HWS); do \
		$(MAKE) --no-print-directory -C $$d clean || exit 1; \
	done
	@rm -rf build build-asan build-cov $(COVERAGE_DIR)
	@echo "Каталоги сборки и отчет покрытия удалены."

# cpp_hse_ripoff

Домашние работы по C++. Каждая работа — отдельный каталог `NN/` со своим
Makefile, сборка через Make, тесты на GoogleTest (из apt), стиль — Google C++
Style.

[![CI](https://github.com/Unknown-reader/cpp_hse_ripoff/actions/workflows/ci.yml/badge.svg)](https://github.com/Unknown-reader/cpp_hse_ripoff/actions/workflows/ci.yml)

## Требования

- Компилятор `g++` с поддержкой C++20 (в CI дополнительно проверяется `clang++`)
- `make`
- `libgtest-dev` — заголовки и статические библиотеки GoogleTest (нужен для
  `make build`, `make test`, `make sanitize`, `make coverage`)
- `clang-format`, `clang-tidy`, `cppcheck`, `cpplint` — инструменты качества
  (нужны только для `make lint`, `make format` и `make format-check`)
- `gcovr` — для `make coverage`

Все зависимости есть в штатных репозиториях Ubuntu/WSL (`cpplint` и `gcovr` — в
`universe`), Python/pip не нужен. Установка на «чистой» системе:

```bash
sudo apt-get install -y make g++ libgtest-dev \
  clang-format clang-tidy cppcheck cpplint gcovr
```

## GoogleTest

Все работы используют GoogleTest и берут его из системных пакетов
(`libgtest-dev`), без копирования библиотек в репозиторий. GoogleTest
подключается только при линковке тестового бинарника (`GTEST_LDLIBS` в
`NN/Makefile`):

```make
GTEST_LDLIBS = -lgtest -lgtest_main -pthread
```

GoogleTest обязателен для `make build`, `make test`, `make sanitize` и
`make coverage` — без него не соберется тестовый бинарник (`<gtest/gtest.h>` и
библиотеки). Для `make lint` и `make format` gtest не нужен.

Пример тестов на GoogleTest — `01/tests/test_solution.cpp`.

## Структура

```
.
├── Makefile                # корневой: запускает цели по работам из списка HWS
├── .clang-format           # профиль Google, 80 колонок, стандарт C++20
├── .clang-tidy             # правила статического анализа
├── .gitignore              # сборка, покрытие, кэши инструментов
├── 01/                     # пример готовой работы
│   ├── Makefile            # самодостаточный Makefile работы
│   ├── include/hw01/solution.hpp
│   ├── src/solution.cpp
│   └── tests/test_solution.cpp
└── .github/workflows/      # ci.yml, pages.yml
```

Сборка — чистый `make` + `g++`, без CMake. GoogleTest берется из системы из
пакета `libgtest-dev` (см. раздел «GoogleTest»). У каждой работы свой полный
Makefile (файлы работ намеренно повторяются — работы независимы друг от друга).

## Быстрый старт

```bash
make help                 # список команд
make test  HW=01          # собрать и прогнать тесты работы 01
make build HW=01          # собрать работу, не запуская тесты
```

Собрать и протестировать сразу все работы из `HWS`:

```bash
make build
make test
```

## Команды

| Команда | Назначение |
|---|---|
| `make build [HW=NN]` | Собрать все или только работу `NN` |
| `make test [HW=NN]` | Собрать и прогнать тесты |
| `make sanitize [HW=NN]` | Сборка и тесты под ASan/UBSan |
| `make coverage [HW=NN]` | Отчет о покрытии (`coverage/index.html`) |
| `make lint [HW=NN]` | cpplint + clang-tidy + cppcheck |
| `make format` | Автоформатирование clang-format по всему репозиторию |
| `make format-check` | Проверка форматирования (как в CI) |
| `make clean` | Удалить каталоги сборки и отчеты покрытия |

Результаты сборки складываются в `build/NN/`, санитайзеры — в
`build-asan/NN/`, покрытие — в `build-cov/NN/` (все каталоги в `.gitignore`).
Отчет покрытия отдельной работы пишется в `NN/coverage/`, сводный отчет по всем
работам — в корневой `coverage/`.

Команды можно вызывать и напрямую из каталога работы:

```bash
cd 01
make test
```

## Как добавить работу

1. Создайте каталог `NN/` (например, `02/`).
2. Скопируйте `Makefile` из любой готовой работы (он самодостаточен, менять в
   нем ничего не нужно):
   ```bash
   mkdir -p 02 && cp 01/Makefile 02/
   mkdir -p 02/include/hw02 02/src 02/tests
   ```
3. Добавьте заголовок, исходник и тест по образцу `01/`.
4. **Допишите номер в `HWS`** в корневом `Makefile` (например, `HWS := 01 02`),
   чтобы корневые команды видели работу.
5. Проверьте локально: `make test HW=02`, `make lint HW=02`,
   `make sanitize HW=02`.

## Стиль кода

Проект следует [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html):

- отступ 2 пробела, ширина 80 колонок (`.clang-format`, профиль `Google`);
- имена: `CamelCase` для типов и функций, `snake_case` для переменных,
  `snake_case_` для приватных полей, `kCamelCase` для констант;
- `#define`-guard'ы в заголовках (`HW07_SOLUTION_HPP_`);
- порядок `#include` проверяет cpplint.

Проверки выполняют три инструмента: `clang-format` (форматирование),
`cpplint` (правила Google) и `clang-tidy` + `cppcheck` (статический анализ).
Все они блокирующие — CI упадет при нарушении.

## CI/CD

Пайплайн описан в `.github/workflows/` и запускается автоматически.

**`.github/workflows/ci.yml`** — на каждый `push` и `pull_request` в `main`,
а также вручную (`workflow_dispatch`):

- `build-and-test` — матрица `{gcc, clang}` с `-Werror`;
- `sanitizers` — сборка и тесты под AddressSanitizer и UBSan;
- `quality` — `clang-format --dry-run --Werror`, cpplint, clang-tidy, cppcheck;
- `coverage` — покрытие через gcovr + gcov, сводка в Summary и артефакт
  `coverage/`.

**`.github/workflows/pages.yml`** — по push в `main`: HTML-отчет о покрытии
публикуется на GitHub Pages.

### Разовая настройка репозитория

- **Settings → Pages → Source = GitHub Actions** — иначе `pages.yml` не
  задеплоит отчет.
- (Необязательно) **Settings → Branches** — защита `main` с обязательными
  зелеными проверками CI.

### Типичный рабочий цикл

```bash
git switch -c hw07
mkdir -p 07 && cp 01/Makefile 07/ && mkdir -p 07/include/hw07 07/src 07/tests
# ... пишем код и тесты, дописываем 07 в HWS ...
make format && make lint HW=07 && make sanitize HW=07 && make coverage HW=07
git add -A && git commit -m "hw07: ..." && git push -u origin hw07
gh pr create --fill          # CI станет обязательной проверкой
```

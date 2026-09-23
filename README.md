# cpp_hse_ripoff

Домашние работы по C++. Каждая работа — отдельный каталог `NN/` со своим
Makefile, сборка через Make, тесты на GoogleTest (из apt), стиль — Google C++
Style.

[![CI](https://github.com/Unknown-reader/cpp_hse_ripoff/actions/workflows/ci.yml/badge.svg)](https://github.com/Unknown-reader/cpp_hse_ripoff/actions/workflows/ci.yml)

## Требования

- Компилятор `g++` с поддержкой C++20 (в CI дополнительно проверяется `clang++`)
- `make`
- `libgtest-dev` — заголовки и библиотека GoogleTest
- Инструменты качества (нужны только для `make lint` и `make format`):
  `clang-format`, `clang-tidy`, `cppcheck`, `cpplint`
- `gcovr` для `make coverage`

Установка (Ubuntu/WSL):

```bash
sudo apt-get install -y g++ libgtest-dev clang-format clang-tidy cppcheck
pip install --user --break-system-packages cpplint gcovr
```

## Структура

```
.
├── Makefile                # корневой: запускает цели по работам из списка HWS
├── 01/                     # пример готовой работы
│   ├── Makefile            # самодостаточный Makefile работы
│   ├── include/hw01/solution.hpp
│   ├── src/solution.cpp
│   └── tests/test_solution.cpp
└── .github/workflows/      # ci.yml, pages.yml
```

Сборка — чистый `make` + `g++`, без CMake. GoogleTest линкуется из системы
(`-lgtest -lgtest_main -pthread`). У каждой работы свой полный Makefile (файлы
работ намеренно повторяются — работы независимы друг от друга).

## Быстрый старт

```bash
make help                 # список команд
make test  HW=01          # собрать и прогнать тесты работы 01
make build HW=01          # только собрать
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

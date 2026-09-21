# cpp_hse_ripoff

Домашние работы по C++. Каждая работа — отдельный каталог `NN/`, сборка через
Makefile поверх CMake, тесты на GoogleTest, стиль — Google C++ Style.

[![CI](https://github.com/Unknown-reader/cpp_hse_ripoff/actions/workflows/ci.yml/badge.svg)](https://github.com/Unknown-reader/cpp_hse_ripoff/actions/workflows/ci.yml)

## Требования

- CMake ≥ 3.20
- Компилятор `clang++` с поддержкой C++20 (≥ 16)
- `make`
- Инструменты качества (нужны только для `make lint` и `make format`):
  `clang-format`, `clang-tidy`, `run-clang-tidy`, `cppcheck`, `cpplint`
- `gcovr` и `llvm-cov` для `make coverage`

Установка (Ubuntu/WSL):

```bash
sudo apt-get install -y cmake clang llvm clang-format clang-tidy cppcheck
pip install --user --break-system-packages cpplint gcovr
```

GoogleTest не нужно ставить руками — CMake скачает его автоматически
(FetchContent, тег `v1.17.0`) при первой конфигурации.

## Структура

```
.
├── CMakeLists.txt          # корневой проект: C++20, авто-поиск работ NN/
├── cmake/                  # общие флаги и опции (sanitizers/coverage/Werror)
├── Makefile                # единая точка входа
├── template/               # каркас новой работы
├── scripts/new_hw.sh       # генератор каркаса
├── 01/                     # пример готовой работы
│   ├── CMakeLists.txt
│   ├── include/hw01/solution.hpp
│   ├── src/solution.cpp
│   └── tests/test_solution.cpp
└── .github/workflows/      # ci.yml, pages.yml
```

## Быстрый старт

```bash
make help                 # список команд
make new HW=02            # создать каркас работы 02
# реализовать 02/src/... и тесты 02/tests/...
make build HW=02          # собрать только работу 02
make test  HW=02          # прогнать только её тесты
```

Собрать и протестировать сразу все работы:

```bash
make build
make test
```

## Команды

| Команда | Назначение |
|---|---|
| `make configure` | Настроить CMake (скачивает GoogleTest) |
| `make build [HW=NN]` | Собрать всё или только работу `NN` |
| `make test [HW=NN]` | Собрать и прогнать тесты |
| `make sanitize [HW=NN]` | Сборка и тесты под ASan/UBSan |
| `make coverage [HW=NN]` | Отчёт о покрытии (`coverage/index.html`) |
| `make lint [HW=NN]` | cpplint + clang-tidy + cppcheck |
| `make lint-style [HW=NN]` | Только cpplint (Google C++ Style) |
| `make format [HW=NN]` | Автоформатирование clang-format |
| `make format-check [HW=NN]` | Проверка форматирования (как в CI) |
| `make new HW=NN` | Создать каркас новой работы |
| `make clean` | Удалить каталоги сборки и отчёт покрытия |

Полезные переменные: `BUILD_TYPE` (`Debug`/`Release`), `JOBS`, `BUILD_DIR`,
`CMAKE_FLAGS`.

По умолчанию сборка идёт в каталог `build/` рядом с исходниками (он исключён
через `.gitignore`).

## Как добавить работу

1. `make new HW=07` — создастся `07/` с заголовком, исходником и тестом.
2. Реализуйте задание в `07/src/`, объявления — в
   `07/include/hw07/solution.hpp`.
3. Добавьте тесты в `07/tests/`.
4. Проверьте локально: `make test HW=07`, `make lint HW=07`,
   `make sanitize HW=07`.

Новые каталоги `NN/` подхватываются автоматически при следующей конфигурации
(каталог-обёртка не требует правок).

## Стиль кода

Проект следует [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html):

- отступ 2 пробела, ширина 80 колонок (`.clang-format`, профиль `Google`);
- имена: `CamelCase` для типов и функций, `snake_case` для переменных,
  `snake_case_` для приватных полей, `kCamelCase` для констант;
- `#define`-guard'ы в заголовках (`HW07_SOLUTION_HPP_`);
- порядок `#include` проверяет cpplint.

Проверки выполняют три инструмента: `clang-format` (форматирование),
`cpplint` (правила Google) и `clang-tidy` + `cppcheck` (статический анализ).
Все они блокирующие — CI упадёт при нарушении.

## CI/CD

Пайплайн описан в `.github/workflows/` и запускается автоматически.

**`.github/workflows/ci.yml`** — на каждый `push` и `pull_request` в `main`,
а также вручную (`workflow_dispatch`):

- `build-and-test` — clang × `{Debug, Release}` с `-Werror`;
- `sanitizers` — сборка и тесты под AddressSanitizer и UBSan;
- `quality` — `clang-format --dry-run --Werror`, cpplint, clang-tidy, cppcheck;
- `coverage` — покрытие через gcovr + llvm-cov, сводка в Summary и артефакт
  `coverage/`.

**`.github/workflows/pages.yml`** — по push в `main`: HTML-отчёт о покрытии
публикуется на GitHub Pages.

### Разовая настройка репозитория

- **Settings → Pages → Source = GitHub Actions** — иначе `pages.yml` не
  задеплоит отчёт.
- (Необязательно) **Settings → Branches** — защита `main` с обязательными
  зелёными проверками CI.

### Типичный рабочий цикл

```bash
git switch -c hw07
make new HW=07
# ... пишем код и тесты ...
make format && make lint HW=07 && make sanitize HW=07 && make coverage HW=07
git add -A && git commit -m "hw07: ..." && git push -u origin hw07
gh pr create --fill          # CI станет обязательной проверкой
```

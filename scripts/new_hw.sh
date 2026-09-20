#!/usr/bin/env bash
#
# Генерирует каркас новой домашней работы из template/.
#
# Использование: scripts/new_hw.sh 09
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly TEMPLATE_DIR="${REPO_ROOT}/template"

usage() {
  echo "Использование: $0 <NN>  (NN — двузначный номер работы, например 09)" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

readonly number="$1"

if [[ ! "${number}" =~ ^[0-9]{2}$ ]]; then
  echo "Ошибка: номер должен состоять из двух цифр, получено '${number}'." >&2
  usage
fi

readonly destination="${REPO_ROOT}/${number}"

if [[ -e "${destination}" ]]; then
  echo "Ошибка: каталог '${number}' уже существует." >&2
  exit 1
fi

if [[ ! -d "${TEMPLATE_DIR}" ]]; then
  echo "Ошибка: не найден каталог шаблона '${TEMPLATE_DIR}'." >&2
  exit 1
fi

cp -r "${TEMPLATE_DIR}" "${destination}"

if [[ -d "${destination}/include/hwNN" ]]; then
  mv "${destination}/include/hwNN" "${destination}/include/hw${number}"
fi

while IFS= read -r -d '' file; do
  sed -i \
    -e "s/HWNN/HW${number}/g" \
    -e "s/hwNN/hw${number}/g" \
    "${file}"
done < <(find "${destination}" -type f -print0)

echo "Создана работа '${number}':"
echo "  ${number}/include/hw${number}/solution.hpp"
echo "  ${number}/src/solution.cpp"
echo "  ${number}/app/main.cpp"
echo "  ${number}/tests/test_solution.cpp"
echo
echo "Дальше:"
echo "  make build HW=${number}"
echo "  make test  HW=${number}"

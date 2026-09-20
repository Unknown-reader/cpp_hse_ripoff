#include <cerrno>
#include <cstdint>
#include <cstdlib>
#include <iostream>

#include "hw01/solution.hpp"

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cerr << "Использование: " << argv[0] << " <число>\n";
    return EXIT_FAILURE;
  }

  errno = 0;
  char* end = nullptr;
  const std::int64_t value = std::strtoll(argv[1], &end, 10);
  if (errno != 0 || end == argv[1] || *end != '\0') {
    std::cerr << "Не удалось разобрать число: " << argv[1] << '\n';
    return EXIT_FAILURE;
  }

  std::cout << value
            << (hw01::IsPrime(value) ? " — простое\n" : " — не простое\n");
  return EXIT_SUCCESS;
}

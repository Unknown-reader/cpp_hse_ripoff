#include <cstdlib>
#include <iostream>

#include "hwNN/solution.hpp"

int main(int argc, char** argv) {
  if (argc != 3) {
    std::cerr << "Использование: " << argv[0] << " <lhs> <rhs>\n";
    return EXIT_FAILURE;
  }
  const int lhs = std::atoi(argv[1]);
  const int rhs = std::atoi(argv[2]);
  std::cout << hwNN::Add(lhs, rhs) << '\n';
  return EXIT_SUCCESS;
}

#include "hw01/solution.hpp"

namespace hw01 {

bool IsPrime(std::int64_t value) {
  if (value < 2) {
    return false;
  }
  for (std::int64_t divisor = 2; divisor <= value / divisor; ++divisor) {
    if (value % divisor == 0) {
      return false;
    }
  }
  return true;
}

}  // namespace hw01

#include "gtest/gtest.h"
#include "hwNN/solution.hpp"

namespace {

TEST(AddTest, SumsPositiveNumbers) {
  EXPECT_EQ(hwNN::Add(2, 3), 5);
}

TEST(AddTest, HandlesNegativeNumbers) {
  EXPECT_EQ(hwNN::Add(-4, 1), -3);
}

}  // namespace

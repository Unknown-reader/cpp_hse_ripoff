#include <cstdint>

#include "gtest/gtest.h"
#include "hw01/solution.hpp"

namespace {

TEST(IsPrimeTest, RejectsNumbersBelowTwo) {
  EXPECT_FALSE(hw01::IsPrime(-7));
  EXPECT_FALSE(hw01::IsPrime(0));
  EXPECT_FALSE(hw01::IsPrime(1));
}

TEST(IsPrimeTest, AcceptsSmallestPrimes) {
  EXPECT_TRUE(hw01::IsPrime(2));
  EXPECT_TRUE(hw01::IsPrime(3));
  EXPECT_TRUE(hw01::IsPrime(5));
}

TEST(IsPrimeTest, RejectsComposites) {
  EXPECT_FALSE(hw01::IsPrime(4));
  EXPECT_FALSE(hw01::IsPrime(9));
  EXPECT_FALSE(hw01::IsPrime(100));
}

TEST(IsPrimeTest, HandlesLargePrimesAndSquares) {
  constexpr std::int64_t kLargePrime = 104729;
  EXPECT_TRUE(hw01::IsPrime(kLargePrime));
  EXPECT_FALSE(hw01::IsPrime(kLargePrime * kLargePrime));
}

}  // namespace

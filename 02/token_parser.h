#include <string>

using func_digit_ptr = void(*)();
using func_str_ptr = void(*)();

void parse(const std::string& text,
           func_digit_ptr digit_callback = nullptr,
           func_str_ptr string_callback = nullptr);
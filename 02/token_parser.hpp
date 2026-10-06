#include <string>

class TokenParser {
public:
    TokenParser() = default;

    void Parse(const std::string& text) const;
};
#include <string>
#include <functional>

std::functional<void(void)> StartCallbackPtr;

class TokenParser {
public:
    TokenParser() = default;

    void SetStartCallback( StartCallbackPtr ptr );

    void Parse(const std::string& text) const;
};
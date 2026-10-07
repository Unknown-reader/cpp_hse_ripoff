#include <string>
#include <functional>

std::functional<void(void)> StartCallbackPtr;
std::functional<void(void)> EndCallbackPtr;

class TokenParser {
public:
    TokenParser() = default;

    void SetStartCallback( StartCallbackPtr Start );

    void SetEndCallback( EndCallbackPtr End );

    void Parse(const std::string& text) const;
};
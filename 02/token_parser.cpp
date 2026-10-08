#include "token_parser.hpp"

TokenParser::SetStartCallback( StartCallbackPtr Start )
{
    StartCallback = Start;
}
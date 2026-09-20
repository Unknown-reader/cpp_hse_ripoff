add_library(project_warnings INTERFACE)
target_compile_options(
  project_warnings
  INTERFACE $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wall>
            $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wextra>
            $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wpedantic>
            $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wshadow>
            $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wconversion>
            $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wsign-conversion>
            $<$<CXX_COMPILER_ID:MSVC>:/W4>
)

add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_20)
target_link_libraries(project_options INTERFACE project_warnings)

option(WERROR "Считать предупреждения компилятора ошибками" OFF)
option(ENABLE_SANITIZERS "Включить AddressSanitizer и UndefinedBehaviorSanitizer" OFF)
option(ENABLE_COVERAGE "Включить инструментирование покрытия" OFF)

if(WERROR)
  target_compile_options(
    project_options
    INTERFACE $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Werror>
  )
endif()

if(ENABLE_SANITIZERS)
  target_compile_options(
    project_options
    INTERFACE -fsanitize=address,undefined -fno-omit-frame-pointer -g
  )
  target_link_options(project_options INTERFACE -fsanitize=address,undefined)
endif()

if(ENABLE_COVERAGE)
  target_compile_options(project_options INTERFACE --coverage -O0 -g)
  target_link_options(project_options INTERFACE --coverage)
endif()

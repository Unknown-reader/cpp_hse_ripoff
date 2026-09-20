cmake_minimum_required(VERSION 3.20)

project(cpp_hse_ripoff LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Тип сборки" FORCE)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(ProjectOptions)

include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG v1.17.0
  GIT_SHALLOW TRUE
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

include(CTest)
enable_testing()

file(
  GLOB hw_dirs
  CONFIGURE_DEPENDS
  LIST_DIRECTORIES true
  "${CMAKE_CURRENT_SOURCE_DIR}/[0-9][0-9]"
)

foreach(hw_dir IN LISTS hw_dirs)
  if(IS_DIRECTORY "${hw_dir}" AND EXISTS "${hw_dir}/CMakeLists.txt")
    add_subdirectory("${hw_dir}")
  endif()
endforeach()

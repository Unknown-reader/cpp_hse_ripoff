get_filename_component(hw_name "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(hw_target "hw${hw_name}")

file(GLOB hw_sources CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

add_library(${hw_target} STATIC ${hw_sources})
target_include_directories(
  ${hw_target}
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_link_libraries(${hw_target} PUBLIC project_options)

file(GLOB hw_tests CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp")
if(hw_tests)
  add_executable(${hw_target}_tests ${hw_tests})
  target_link_libraries(
    ${hw_target}_tests
    PRIVATE ${hw_target} GTest::gtest_main
  )
  include(GoogleTest)
  gtest_discover_tests(${hw_target}_tests PROPERTIES LABELS ${hw_target})
endif()

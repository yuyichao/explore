project(cpp.extern_template CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++0x -Wall -Wextra")

set(EXTERN_TEMPLATE_SOURCES
  lib.cpp
  main.cpp)

add_executable(cpp_extern_template ${EXTERN_TEMPLATE_SOURCES})
add_run(test_cpp_extern_template
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_extern_template)

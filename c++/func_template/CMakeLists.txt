project(cpp.func_template CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++11 -Wall -Wextra")

set(FUNC_TEMPLATE_SOURCES
  main.cpp)

add_executable(cpp_func_template ${FUNC_TEMPLATE_SOURCES})
add_run(test_cpp_func_template
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_func_template)

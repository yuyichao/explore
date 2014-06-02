project(cpp.template_template CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++0x -Ofast -Wall -Wextra")

set(TEMPLATE_TEMPLATE_SOURCES
  main.cpp)

add_executable(cpp_template_template ${TEMPLATE_TEMPLATE_SOURCES})
add_run(test_cpp_template_template
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_template_template)

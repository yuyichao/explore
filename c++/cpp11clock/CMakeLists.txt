project(cpp.cpp11clock CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++14 -Wall -Wextra")

set(CPP11CLOCK_SOURCES
  main.cpp)

add_executable(cpp_cpp11clock ${CPP11CLOCK_SOURCES})
add_run(test_cpp_cpp11clock
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_cpp11clock)

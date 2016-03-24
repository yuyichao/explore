project(cpp.enable_if_func CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++11 -Wall -Wextra")

set(ENABLE_IF_FUNC_SOURCES
  enable_if_func.cpp)

add_executable(cpp_enable_if_func ${ENABLE_IF_FUNC_SOURCES})
add_run(test_cpp_enable_if_func
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_enable_if_func)

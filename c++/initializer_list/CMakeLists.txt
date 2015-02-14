project(cpp.initializer_list CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++14 -Wall -Wextra")

set(INITIALIZER_LIST_SOURCES
  main.cpp)

add_executable(cpp_initializer_list ${INITIALIZER_LIST_SOURCES})
add_run(test_cpp_initializer_list
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_initializer_list)

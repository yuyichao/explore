project(cpp.call_tuple CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++0x -Ofast")

set(CALL_TUPLE_SOURCES
  main.cpp)

add_executable(cpp_call_tuple ${CALL_TUPLE_SOURCES})
add_run(test_cpp_call_tuple
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_call_tuple)

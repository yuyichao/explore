project(cpp.unique_ptr_copy CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++0x -Wall -Wextra")

set(UNIQUE_PTR_COPY_SOURCES
  main.cpp)

add_executable(cpp_unique_ptr_copy ${UNIQUE_PTR_COPY_SOURCES})
add_run(test_cpp_unique_ptr_copy
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_unique_ptr_copy)

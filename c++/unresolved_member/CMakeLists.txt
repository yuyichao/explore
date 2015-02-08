project(cpp.unresolved_member CXX)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_definitions("-std=c++0x -Wall -Wextra")

set(UNRESOLVED_MEMBER_SOURCES
  main.cpp)

add_executable(cpp_unresolved_member ${UNRESOLVED_MEMBER_SOURCES})
add_run(test_cpp_unresolved_member
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cpp_unresolved_member)

project(general_c.tostr C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  tostr.c)

add_executable(c_tostr ${SOURCES})
add_run(test_c_tostr
  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/c_tostr")

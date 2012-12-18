project(general_c.tohex C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(TOHEX_SOURCES
  tohex.c)

add_executable(c_tohex ${TOHEX_SOURCES})
add_run(test_c_tohex
  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/c_tohex")

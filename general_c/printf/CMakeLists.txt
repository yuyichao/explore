project(general_c.printf C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  lib.c
  main.c
  )

add_executable(c_printf ${SOURCES})
target_link_libraries(c_printf rt)
add_run(test_c_printf
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_printf)

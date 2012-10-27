project(general_c.memcmp_dup C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(MEMCMP_DUP_SOURCES
  main.c
  lib.c)

add_executable(c_memcmp_dup ${MEMCMP_DUP_SOURCES})
target_link_libraries(c_memcmp_dup rt)
add_run(test_c_memcmp_dup
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_memcmp_dup)

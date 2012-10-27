project(general_c.strdup C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(STRDUP_SOURCES
  main.c
  lib.c)

add_executable(c_strdup ${STRDUP_SOURCES})
target_link_libraries(c_strdup rt)
add_run(test_c_strdup
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_strdup)

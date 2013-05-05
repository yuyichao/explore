project(general_c.bsearch C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  main.c
  lib.c)

add_executable(c_bsearch ${SOURCES})
target_link_libraries(c_bsearch rt)
add_run(test_c_bsearch
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_bsearch)

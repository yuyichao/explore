project(general_c.realloc C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(REALLOC_SOURCES
  main.c)

add_executable(c_realloc ${REALLOC_SOURCES})
target_link_libraries(c_realloc rt)
add_run(test_c_realloc
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_realloc)

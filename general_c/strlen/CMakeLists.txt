project(general_c.strlen C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(STRLEN_SOURCES
  main.c)

add_executable(c_strlen ${STRLEN_SOURCES})
target_link_libraries(c_strlen)
add_run(test_c_strlen
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_strlen)

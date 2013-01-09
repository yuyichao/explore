project(general_c.memcpy C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  lib.c
  lib.cpp
  main.cpp
  )

add_executable(c_memcpy ${SOURCES})
target_link_libraries(c_memcpy rt)
add_run(test_c_memcpy
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_memcpy)

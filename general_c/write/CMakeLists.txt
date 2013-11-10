project(general_c.write C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  main.c
  )

add_executable(c_write ${SOURCES})
# target_link_libraries(c_write rt)
add_run(test_c_write
  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/c_write"
  "${CMAKE_CURRENT_BINARY_DIR}/test")

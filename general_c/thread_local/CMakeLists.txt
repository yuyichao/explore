project(general_c.thread_local C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  main.c
  )

add_executable(c_thread_local ${SOURCES})
target_link_libraries(c_thread_local rt pthread)
add_run(test_c_thread_local
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_thread_local)

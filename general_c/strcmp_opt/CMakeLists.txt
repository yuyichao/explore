project(general_c.strcmp_opt C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  main.c)

add_definitions(-O2 -g)
add_executable(c_strcmp_opt ${SOURCES})
target_link_libraries(c_strcmp_opt rt)
add_run(test_c_strcmp_opt
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_strcmp_opt)

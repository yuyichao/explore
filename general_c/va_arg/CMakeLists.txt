project(general_c.va_arg C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(VA_ARG_SOURCES
  main.c)

add_executable(c_vaarg ${VA_ARG_SOURCES})
add_run(test_c_vaarg
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_vaarg)

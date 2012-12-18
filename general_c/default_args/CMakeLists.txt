project(general_c.default_args C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(DEFAULT_ARGS_SOURCES
  main.c)

add_executable(c_default_args ${DEFAULT_ARGS_SOURCES})
add_run(test_c_default_args
  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/c_default_args")

set(DEFAULT_ARGS_SOURCES
  main.cpp)

add_executable(cpp_default_args ${DEFAULT_ARGS_SOURCES})
add_run(test_cpp_default_args
  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/cpp_default_args")

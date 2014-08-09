project(lxc.ust_ns C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(UST_NS_SOURCES
  main.c)

add_executable(lxc_ust_ns ${UST_NS_SOURCES})
add_run(test_lxc_ust_ns
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/lxc_ust_ns child_host)

project(general_c.pwrite_self_mem C)

set(CMAKE_C_FLAGS "-std=gnu11 -pthread -O3 ${CMAKE_C_FLAGS} -D_FILE_OFFSET_BITS=64")
set(CMAKE_CXX_FLAGS "-std=gnu++11 -pthread -O3 ${CMAKE_CXX_FLAGS} -D_FILE_OFFSET_BITS=64")

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  main.cpp)

add_executable(c_pwrite_self_mem ${SOURCES})
target_link_libraries(c_pwrite_self_mem rt pthread)
add_run(test_c_pwrite_self_mem
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_pwrite_self_mem)

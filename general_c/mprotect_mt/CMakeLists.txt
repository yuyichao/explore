project(general_c.mprotect_mt C)

set(CMAKE_C_FLAGS "-std=gnu11 -pthread -O3 ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-std=gnu++11 -pthread -O3 ${CMAKE_CXX_FLAGS}")

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  main.cpp)

add_executable(c_mprotect_mt ${SOURCES})
target_link_libraries(c_mprotect_mt rt pthread)
# add_run(test_c_mprotect_mt
#   COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_mprotect_mt)

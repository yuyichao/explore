project(general_c.bench_signals C)

set(CMAKE_C_FLAGS "-std=gnu11 -pthread -O3 ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-std=gnu++11 -pthread -O3 ${CMAKE_CXX_FLAGS}")

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  main.cpp)

add_executable(c_bench_signals ${SOURCES})
target_link_libraries(c_bench_signals rt pthread)
add_run(test_c_bench_signals
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_bench_signals)

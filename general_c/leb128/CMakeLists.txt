project(general_c.leb128 C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  leb128.cpp
  )

set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")

add_executable(c_leb128 ${SOURCES})
target_link_libraries(c_leb128)
add_run(test_c_leb128
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_leb128)

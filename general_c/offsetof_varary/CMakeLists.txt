project(general_c.offsetof_varary C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(OFFSETOF_VARARY_SOURCES
  main.c)

add_definitions(-pedantic)

add_executable(c_offsetof_varary ${OFFSETOF_VARARY_SOURCES})
target_link_libraries(c_offsetof_varary rt)
add_run(test_c_offsetof_varary
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/c_offsetof_varary)

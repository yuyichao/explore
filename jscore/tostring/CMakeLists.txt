project(jscore.tostring C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${JSCORE_INCLUDE_DIRS})
link_directories(${JSCORE_LINK_DIRS})
add_definitions(${JSCORE_FLAGS})

set(TOSTRING_SOURCES
  main.c)

add_executable(to_string ${TOSTRING_SOURCES})
target_link_libraries(to_string ${JSCORE_LINK})
add_run(test_tostring
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/to_string)

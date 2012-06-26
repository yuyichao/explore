project(jscore.prop_list C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${JSCORE_INCLUDE_DIRS})
link_directories(${JSCORE_LINK_DIRS})
add_definitions(${JSCORE_FLAGS})

set(PROP_LIST_SOURCES
  main.c)

add_executable(prop_list ${PROP_LIST_SOURCES})
target_link_libraries(prop_list ${JSCORE_LINK})
add_run(test_prop_list
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/prop_list)

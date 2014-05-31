project(qt5.property)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}"
  ${Qt5Core_INCLUDE_DIRS})

set(SOURCES
  main.cpp)

add_definitions(${Qt5Core_EXECUTABLE_COMPILE_FLAGS})

add_executable(qt5_property ${SOURCES})
target_link_libraries(qt5_property
  ${Qt5Core_LIBRARIES}
  )
add_run(test_qt5_property
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/qt5_property
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

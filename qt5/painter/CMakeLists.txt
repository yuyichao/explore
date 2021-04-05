project(qt5.painter)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}"
  ${Qt5Core_INCLUDE_DIRS})

set(SOURCES
  main.cpp)

add_definitions(${Qt5Core_EXECUTABLE_COMPILE_FLAGS} -std=c++0x)

add_executable(qt5_painter ${SOURCES})
target_link_libraries(qt5_painter
  ${Qt5Core_LIBRARIES}
  ${Qt5Gui_LIBRARIES}
  ${Qt5Widgets_LIBRARIES}
  )
add_run(test_qt5_painter
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/qt5_painter
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

project(qt5.quick_control)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}"
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Gui_INCLUDE_DIRS}
  ${Qt5Widgets_INCLUDE_DIRS}
  ${Qt5Qml_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
  )

set(SOURCES
  main.cpp)

# qt5_wrap_cpp(SOURCES)

add_definitions(${Qt5Core_EXECUTABLE_COMPILE_FLAGS})

add_executable(qt5_quick_control ${SOURCES})
target_link_libraries(qt5_quick_control
  ${Qt5Core_LIBRARIES}
  ${Qt5Gui_LIBRARIES}
  ${Qt5Widgets_LIBRARIES}
  ${Qt5Qml_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
  )
add_run(test_qt5_quick_control
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/qt5_quick_control
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

project(qt5.translucent-gl)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}"
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Widgets_INCLUDE_DIRS}
  ${Qt5OpenGL_INCLUDE_DIRS})

set(SOURCES
  main.cpp)

add_definitions(${Qt5Core_EXECUTABLE_COMPILE_FLAGS})

add_executable(qt5_translucent-gl ${SOURCES})
target_link_libraries(qt5_translucent-gl
  ${Qt5Core_LIBRARIES}
  ${Qt5Widgets_LIBRARIES}
  ${Qt5OpenGL_LIBRARIES}
  )
add_run(test_qt5_translucent-gl
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/qt5_translucent-gl
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

project(qt5.webplugin)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}"
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Gui_INCLUDE_DIRS}
  ${Qt5Widgets_INCLUDE_DIRS}
  ${Qt5WebKit_INCLUDE_DIRS}
  ${Qt5WebKitWidgets_INCLUDE_DIRS}
  ${Qt5Sql_INCLUDE_DIRS}
  ${Qt5NetWork_INCLUDE_DIRS}
  )

set(SOURCES
  csvfactory.cpp
  csvview.cpp
  main.cpp
  mainwindow.cpp)

qt5_wrap_cpp(SOURCES
  csvfactory.h
  csvview.h
  mainwindow.h)

add_definitions(${Qt5Core_EXECUTABLE_COMPILE_FLAGS})

add_executable(qt5_webplugin ${SOURCES})
target_link_libraries(qt5_webplugin
  ${Qt5Core_LIBRARIES}
  ${Qt5Gui_LIBRARIES}
  ${Qt5Widgets_LIBRARIES}
  ${Qt5WebKit_LIBRARIES}
  ${Qt5WebKitWidgets_LIBRARIES}
  ${Qt5Sql_LIBRARIES}
  ${Qt5NetWork_LIBRARIES}
  )
add_run(test_qt5_webplugin
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/qt5_webplugin
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

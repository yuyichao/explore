project(qt.webplugin)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}")
include(${QT_USE_FILE})

set(SOURCES
  csvfactory.cpp
  csvview.cpp
  main.cpp
  mainwindow.cpp)

qt4_wrap_cpp(SOURCES
  csvfactory.h
  csvview.h
  mainwindow.h)

add_executable(qt_webplugin ${SOURCES})
target_link_libraries(qt_webplugin ${QT_LIBRARIES})
add_run(test_qt_webplugin
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/qt_webplugin
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

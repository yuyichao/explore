project(gdk.keyevent C)

check_all_modules(KE_MAIN
  GTK REQUIRED gtk+-3.0
  WEBKIT REQUIRED webkitgtk-3.0)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${KE_MAIN_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GDK_MODULES_INCLUDE_DIRS})
add_definitions(${KE_MAIN_FLAGS})
add_definitions(${GDK_MODULES_FLAGS})

set(LIB_KEYEVENT_SOURCES
  event.c)
set(MAIN_KEYEVENT_SOURCES
  main.c)

add_library(keyevent SHARED ${LIB_KEYEVENT_SOURCES})
target_link_libraries(keyevent dl)
add_executable(test_keyevent ${MAIN_KEYEVENT_SOURCES})
target_link_libraries(test_keyevent ${KE_MAIN_LINK})

add_run(run_gdk_keyevent
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  COMMAND "LD_PRELOAD=${CMAKE_CURRENT_BINARY_DIR}/libkeyevent.so"
  "GTK_IM_MODULE=xim"
  "${CMAKE_CURRENT_BINARY_DIR}/test_keyevent")

project(xlib.selection NONE)

check_all_modules(XFIXES_MODULES
  XFIXES REQUIRED xfixes)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${XFIXES_MODULES_INCLUDE_DIRS})
add_definitions(${XFIXES_MODULES_FLAGS})

set(MAIN_SELECTION_SOURCES
  main.c)

add_executable(test_selection ${MAIN_SELECTION_SOURCES})
target_link_libraries(test_selection ${XFIXES_MODULES_LINK} ${XLIB_MODULES_LINK})

add_run(run_xlib_selection
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/test_selection")

project(xlib NONE)

check_all_modules(XLIB_MODULES
  XLIB REQUIRED x11)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${XLIB_MODULES_INCLUDE_DIRS})
add_definitions(${XLIB_MODULES_FLAGS})

add_subdirectory(selection)

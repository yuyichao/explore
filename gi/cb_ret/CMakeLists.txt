project(gi.cb_ret C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GI_MODULES_INCLUDE_DIRS})
link_directories(${GI_MODULES_LINK_DIRS})
add_definitions(${GI_MODULES_FLAGS})

set(LIB_CB_RET_SOURCES
  mobject.c)
set(LIB_CB_RET_HEADERS
  mobject.h)

add_library(cb_ret SHARED ${LIB_CB_RET_SOURCES})
target_link_libraries(cb_ret ${GI_MODULES_LINK})

gobject_introspection(
  FILENAME Testvm-0.1.gir
  NSVERSION 0.1
  INCLUDE GObject-2.0 GLib-2.0
  PACKAGE_EXPORT testvm
  LIBRARY cb_ret
  SCANNER_ARGS --warn-all --add-include-path=${CMAKE_CURRENT_SOURCE_DIR}
  COMPILER_ARGS "--includedir=${CMAKE_CURRENT_SOURCE_DIR}"
  SYMBOL_PREFIXES testvm
  SOURCES ${LIB_CB_RET_SOURCES} ${LIB_CB_RET_HEADERS}
  QUIET
  )

add_run(test_cb_ret COMMAND GI_TYPELIB_PATH=${CMAKE_CURRENT_BINARY_DIR}
  LD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/test.py)

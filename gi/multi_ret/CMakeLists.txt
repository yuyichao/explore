project(gi.multi_ret C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GI_MODULES_INCLUDE_DIRS})
link_directories(${GI_MODULES_LINK_DIRS})
add_definitions(${GI_MODULES_FLAGS})

set(LIB_MULTI_RET_SOURCES
  foo.c)
set(LIB_MULTI_RET_HEADERS
  foo.h)

add_library(multi-ret SHARED ${LIB_MULTI_RET_SOURCES})
target_link_libraries(multi-ret ${GI_MODULES_LINK})

gobject_introspection(
  FILENAME Foo-0.1.gir
  NSVERSION 0.1
  INCLUDE GObject-2.0 GLib-2.0
  PACKAGE_EXPORT foo
  LIBRARY multi-ret
  SCANNER_ARGS --warn-all --add-include-path=${CMAKE_CURRENT_SOURCE_DIR}
  COMPILER_ARGS "--includedir=${CMAKE_CURRENT_SOURCE_DIR}"
  SYMBOL_PREFIXES foo
  SOURCES ${LIB_MULTI_RET_SOURCES} ${LIB_MULTI_RET_HEADERS}
  QUIET
  )

add_run(test_multi_ret COMMAND GI_TYPELIB_PATH=${CMAKE_CURRENT_BINARY_DIR}
  LD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/multi_ret.py)

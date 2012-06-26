project(gi.non-obj C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GI_MODULES_INCLUDE_DIRS})
link_directories(${GI_MODULES_LINK_DIRS})
add_definitions(${GI_MODULES_FLAGS})

set(LIB_NON_OBJ_SOURCES
  foo.c)
set(LIB_NON_OBJ_HEADERS
  foo.h)

add_library(non-obj SHARED ${LIB_NON_OBJ_SOURCES})
target_link_libraries(non-obj ${GI_MODULES_LINK})

gobject_introspection(
  FILENAME Foo-0.1.gir
  NSVERSION 0.1
  INCLUDE GObject-2.0 GLib-2.0
  PACKAGE_EXPORT foo
  LIBRARY non-obj
  SCANNER_ARGS --warn-all --add-include-path=${CMAKE_CURRENT_SOURCE_DIR}
  COMPILER_ARGS "--includedir=${CMAKE_CURRENT_SOURCE_DIR}"
  SYMBOL_PREFIXES foo
  SOURCES ${LIB_NON_OBJ_SOURCES} ${LIB_NON_OBJ_HEADERS}
  QUIET
  )

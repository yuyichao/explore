project(gi.simple C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GI_MODULES_INCLUDE_DIRS})
link_directories(${GI_MODULES_LINK_DIRS})
add_definitions(${GI_MODULES_FLAGS})

set(LIB_SIMPLE_SOURCES
  mobject.c)
set(LIB_SIMPLE_HEADERS
  mobject.h)

add_library(simple SHARED ${LIB_SIMPLE_SOURCES})
target_link_libraries(simple ${GI_MODULES_LINK})

gobject_introspection(
  FILENAME Testvm-0.1.gir
  NSVERSION 0.1
  INCLUDE GObject-2.0 GLib-2.0
  PACKAGE_EXPORT testvm
  LIBRARY simple
  SCANNER_ARGS --warn-all --add-include-path=${CMAKE_CURRENT_SOURCE_DIR}
  COMPILER_ARGS "--includedir=${CMAKE_CURRENT_SOURCE_DIR}"
  SYMBOL_PREFIXES testvm
  SOURCES ${LIB_SIMPLE_SOURCES} ${LIB_SIMPLE_HEADERS}
  QUIET
  )

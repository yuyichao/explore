project(gi.kb C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GI_MODULES_INCLUDE_DIRS})
link_directories(${GI_MODULES_LINK_DIRS})
add_definitions(${GI_MODULES_FLAGS})

set(LIB_KB_SOURCES
  kb-bibtex.c)
set(LIB_KB_HEADERS
  kb-bibtex.h)

add_library(kb SHARED ${LIB_KB_SOURCES})
target_link_libraries(kb ${GI_MODULES_LINK})

gobject_introspection(
  FILENAME KbBibtex-0.1.gir
  NSVERSION 0.1
  INCLUDE GObject-2.0 GLib-2.0
  PACKAGE_EXPORT kb_bibtex
  LIBRARY kb
  SCANNER_ARGS --warn-all --add-include-path=${CMAKE_CURRENT_SOURCE_DIR}
  COMPILER_ARGS "--includedir=${CMAKE_CURRENT_SOURCE_DIR}"
  SYMBOL_PREFIXES kb_bibtex
  SOURCES ${LIB_KB_SOURCES} ${LIB_KB_HEADERS}
  QUIET
  )

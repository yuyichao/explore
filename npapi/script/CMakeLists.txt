project(npapi.script C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}
  ${NPAPI_INCLUDE_DIRS})

add_definitions(${NPAPI_CFLAGS})

set(SOURCES
  try.c)

add_library(npapi_script_try MODULE
  ${SOURCES})

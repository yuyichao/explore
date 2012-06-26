project(preload.gtkim C)

check_all_modules(GTKIM
  GTK2 REQUIRED gtk+-2.0)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GTKIM_INCLUDE_DIRS})
link_directories(${GTKIM_LINK_DIRS})
add_definitions(${GTKIM_FLAGS})

set(LIB_GTKIM_SOURCES
  gtkim.c)

add_library(pre-gtkim SHARED ${LIB_GTKIM_SOURCES})
target_link_libraries(pre-gtkim dl ${GTKIM_LINK})

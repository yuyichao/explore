project(preload.strcoll C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(LIB_STRCOLL_SOURCES
  lib.c)

add_library(pre-strcoll SHARED ${LIB_STRCOLL_SOURCES})
target_link_libraries(pre-strcoll dl)

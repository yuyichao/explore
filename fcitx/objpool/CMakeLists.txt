project(fcitx.objpool C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SOURCES
  main.c)

add_executable(fcitx-objpool ${SOURCES})
target_link_libraries(fcitx-objpool ${FCITX_LINKS})
add_run(test_fcitx_objpool
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/fcitx-objpool)

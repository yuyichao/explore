project(libffi.basic C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${LIBFFI_INCLUDE_DIRS})
link_directories(${LIBFFI_LINK_DIRS})
add_definitions(${LIBFFI_FLAGS})

set(BASIC_SOURCES
  main.c)

add_executable(libffi_basic ${BASIC_SOURCES})
target_link_libraries(libffi_basic ${LIBFFI_LINK})
add_run(test_libffi_basic
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libffi_basic)

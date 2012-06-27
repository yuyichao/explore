project(libffi.alloc C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${LIBFFI_INCLUDE_DIRS})
link_directories(${LIBFFI_LINK_DIRS})
add_definitions(${LIBFFI_FLAGS})

set(ALLOC_SOURCES
  main.c)

add_executable(libffi_alloc ${ALLOC_SOURCES})
target_link_libraries(libffi_alloc ${LIBFFI_LINK})
add_run(test_libffi_alloc
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libffi_alloc)

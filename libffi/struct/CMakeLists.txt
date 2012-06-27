project(libffi.struct C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${LIBFFI_INCLUDE_DIRS})
link_directories(${LIBFFI_LINK_DIRS})
add_definitions(${LIBFFI_FLAGS})

set(STRUCT_SOURCES
  main.c)

add_executable(libffi_struct ${STRUCT_SOURCES})
target_link_libraries(libffi_struct ${LIBFFI_LINK})
add_run(test_libffi_struct
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libffi_struct)

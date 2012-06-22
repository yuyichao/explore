project(gi.init_hook C)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GI_MODULES_INCLUDE_DIRS})
link_directories(${GI_MODULES_LINK_DIRS})
add_definitions(${GI_MODULES_FLAGS})

set(LIB_INIT_HOOK_SOURCES
  mobject.c
  mderive.c)

add_library(init_hook SHARED ${LIB_INIT_HOOK_SOURCES})
target_link_libraries(init_hook ${GI_MODULES_LINK})

add_executable(run-init-hook main.c)
target_link_libraries(run-init-hook init_hook)
wrap_test(test_init_hook
  ${CMAKE_CURRENT_BINARY_DIR}/run-init-hook)

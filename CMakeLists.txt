cmake_minimum_required(VERSION 2.8)
project(explore)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
include(AddRun)

set(CMAKE_C_FLAGS "-Wall -Wextra -Wno-sign-compare -Wno-unused-parameter ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-Wall -Wextra -Wno-sign-compare -Wno-unused-parameter ${CMAKE_CXX_FLAGS}")
add_definitions("-D_GNU_SOURCE")
include(CheckAll)

add_subdirectory(gi)
add_subdirectory(jscore)
add_subdirectory(preload)
add_subdirectory(libffi)

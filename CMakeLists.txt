cmake_minimum_required(VERSION 2.8)
project(explore NONE)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
include(TestWrapper)

enable_testing()

add_subdirectory(gi)

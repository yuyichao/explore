project(cmake.target_include)

cmake_minimum_required(VERSION 3.0)

add_library(cmake-test-lib-import SHARED IMPORTED)
set_target_properties(cmake-test-lib-import PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "/usr/include"
  IMPORTED_LOCATION /usr/lib/libc.so.6)

set_property(SOURCE lib.cpp APPEND PROPERTY INCLUDE_DIRECTORIES /usr/include)
add_library(cmake-test-lib SHARED lib.cpp)
# set_property(TARGET cmake-test-lib APPEND PROPERTY INCLUDE_DIRECTORIES /usr/include)
target_link_libraries(cmake-test-lib PUBLIC cmake-test-lib-import)

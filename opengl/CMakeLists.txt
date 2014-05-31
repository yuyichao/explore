project(opengl NONE)

check_all_modules(GL_MODULES
  GL REQUIRED gl
  GLU REQUIRED glu)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GL_MODULES_INCLUDE_DIRS})
add_definitions(${GL_MODULES_FLAGS})

# add_subdirectory(simple)

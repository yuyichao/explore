project(opengl NONE)

check_all_modules(GL_MODULES
  GL gl
  GLU glu)

if(NOT GL_FOUND OR NOT GLU_FOUND)
  message("opengl disabled")
  return()
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GL_MODULES_INCLUDE_DIRS})
add_definitions(${GL_MODULES_FLAGS})

# add_subdirectory(simple)

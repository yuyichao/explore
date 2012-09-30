project(gl.simple)

set(GL_SIMPLE_SRC
  main.c)

add_executable(test_gl_simple ${GL_SIMPLE_SRC})
target_link_libraries(test_gl_simple ${GL_MODULES_LINK} glut)

add_run(run_gl_simple
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/test_gl_simple")

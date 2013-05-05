# target
add_custom_target(trycmake_target_target1
  COMMAND echo -e "\\e[36;02mtrycmake_target_target1\\e[00m"
  VERBATIM)

# target: ALL
add_custom_target(trycmake_target_target2 ALL
  COMMAND echo -e "\\e[36;02mtrycmake_target_target2\\e[00m"
  VERBATIM)

# target: required by ALL
add_custom_target(trycmake_target_target3
  COMMAND echo -e "\\e[36;02mtrycmake_target_target3\\e[00m"
  VERBATIM)
add_custom_target(trycmake_target_target4 ALL
  COMMAND echo -e "\\e[36;02mtrycmake_target_target4\\e[00m"
  DEPENDS trycmake_target_target3
  VERBATIM)

# target: depend on file
add_custom_target(trycmake_target_target5
  COMMAND echo -e "\\e[36;02mtrycmake_target_target5\\e[00m"
  DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/a"
  VERBATIM)

# output
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/o1"
  COMMAND echo -e "\\e[36;02mtrycmake_target_output_o1\\e[00m"
  COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/o1"
  VERBATIM)

# output
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/o2"
  COMMAND echo -e "\\e[36;02mtrycmake_target_output_o2\\e[00m"
  COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/o2"
  VERBATIM)
add_custom_target(trycmake_target_target6 ALL
  COMMAND echo -e "\\e[36;02mtrycmake_target_target6\\e[00m"
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/o2"
  VERBATIM)

# output
add_custom_target(trycmake_target_target7
  COMMAND echo -e "\\e[36;02mtrycmake_target_target7\\e[00m"
  VERBATIM)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/o3"
  COMMAND echo -e "\\e[36;02mtrycmake_target_output_o3\\e[00m"
  COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/o3"
  DEPENDS trycmake_target_target7
  VERBATIM)
add_custom_target(trycmake_target_target8 ALL
  COMMAND echo -e "\\e[36;02mtrycmake_target_target8\\e[00m"
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/o3"
  VERBATIM)

# output
add_custom_target(trycmake_target_target9
  COMMAND echo -e "\\e[36;02mtrycmake_target_target9\\e[00m"
  VERBATIM)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/o4"
  COMMAND echo -e "\\e[36;02mtrycmake_target_output_o4\\e[00m"
  COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/o4"
  DEPENDS trycmake_target_target9
  VERBATIM)
add_custom_target(trycmake_target_target10
  COMMAND echo -e "\\e[36;02mtrycmake_target_target10\\e[00m"
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/o4"
  VERBATIM)

# output
add_custom_target(trycmake_target_target11
  COMMAND echo -e "\\e[36;02mtrycmake_target_target11\\e[00m"
  COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/o5"
  VERBATIM)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/o5"
  COMMAND echo -e "\\e[36;02mtrycmake_target_output_o5\\e[00m"
  DEPENDS trycmake_target_target11
  VERBATIM)
add_custom_target(trycmake_target_target12
  COMMAND echo -e "\\e[36;02mtrycmake_target_target12\\e[00m"
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/o5"
  VERBATIM)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/o6"
  COMMAND echo -e "\\e[36;02mtrycmake_target_output_o6\\e[00m"
  COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/o6"
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/o5"
  VERBATIM)
add_custom_target(trycmake_target_target13
  COMMAND echo -e "\\e[36;02mtrycmake_target_target13\\e[00m"
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/o6"
  VERBATIM)

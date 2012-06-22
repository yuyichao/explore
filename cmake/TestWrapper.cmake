get_filename_component(TEST_WRAPPER_PATH
  ${CMAKE_CURRENT_LIST_FILE} PATH)

macro(wrap_test test_name)
  set(__arg_list ${ARGN})
  set(EXTRA_ARG)
  list(GET __arg_list 0 __arg)
  if (__arg STREQUAL "WORKING_DIRECTORY")
    list(REMOVE_AT __arg_list 0)
    list(GET __arg_list 0 __arg)
    list(REMOVE_AT __arg_list 0)
    set(EXTRA_ARG ${EXTRA_ARG} WORKING_DIRECTORY ${__arg})
  endif()
  add_test(${test_name} ${EXTRA_ARG}
    bash ${TEST_WRAPPER_PATH}/TestWrapper.sh ${__arg_list})
endmacro()

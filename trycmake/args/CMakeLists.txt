macro(__test_macro_args __start)
  set(__argc "ARGC")
  math(EXPR __argn_max "${${__argc}} - 1")
  message("ARGN_MAX: ${__argn_max}")
  foreach(__n RANGE ${__start} ${__argn_max} 1)
    message("ARG${__n}: \"${ARGV${__n}}\"")
  endforeach()
endmacro()

function(__test_function_args)
  __test_macro_args(2)
endfunction()

__test_function_args(1 2 3 4 "" d)

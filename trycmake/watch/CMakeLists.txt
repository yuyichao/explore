set(var Nothing)
message("Initial: ${var}")

function(watch_function_1)
  set(var watch_function_1 PARENT_SCOPE)
endfunction()
variable_watch(var1 watch_function_1)
set(var1 a)
message("1: ${var}")

macro(watch_macro_1)
  set(var watch_macro_1)
endmacro()
variable_watch(var2 watch_macro_1)
set(var2 a)
message("2: ${var}")

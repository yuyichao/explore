function(verilog_compile target ifile)
  set(ofile "${CMAKE_CURRENT_BINARY_DIR}/${target}")
  if(NOT IS_ABSOLUTE "${ifile}")
    set(ifile "${CMAKE_CURRENT_SOURCE_DIR}/${ifile}")
  endif()
  add_custom_command(OUTPUT "${ofile}"
    COMMAND iverilog "-o${ofile}" "${ifile}"
    DEPENDS "${ifile}" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  add_custom_target("${target}" ALL DEPENDS "${ofile}")
endfunction()

verilog_compile(arbiter arbiter.v)
verilog_compile(addbit addbit.v)
verilog_compile(adder_hier adder_hier.v)

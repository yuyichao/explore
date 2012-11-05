project(cmake.properties)

function(set_property_list file basename)
  set(argv ${ARGN})
  list(LENGTH argv __len)
  math(EXPR __max "${__len} - 1")
  set_source_files_properties("${file}" PROPERTIES
    "${basename}_MAX" "${__max}")
  foreach(index RANGE ${__max})
    list(GET argv ${index} ele)
    set_source_files_properties("${file}" PROPERTIES
      "${basename}_PROP_${index}" "${ele}")
  endforeach()
endfunction()

function(get_property_list file basename output)
  set(values)
  get_source_file_property(__max "${file}" "${basename}_MAX")
  foreach(index RANGE ${__max})
    get_source_file_property(ele "${file}" "${basename}_PROP_${index}")
    list(APPEND values "${ele}")
  endforeach()
  set(${output} ${values} PARENT_SCOPE)
endfunction()

set(value 3 4 5)

set_property_list(source custom_property1 ${value})
get_property_list(source custom_property1 prop)
message("${prop}")

foreach(a RANGE 3)
  message("x${a}x")
endforeach()

foreach(a RANGE 1 3)
  message("x${a}x")
endforeach()

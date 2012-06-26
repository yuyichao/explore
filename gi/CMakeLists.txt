project(gi NONE)

include(GObjectIntrospection)

check_all_modules(GI_MODULES
  GLIB2 REQUIRED glib-2.0
  GOBJECT2 REQUIRED gobject-2.0)

add_subdirectory(non-obj)
add_subdirectory(kb)
add_subdirectory(simple)
add_subdirectory(virtual)
add_subdirectory(init_hook)
add_subdirectory(pyinit)
add_subdirectory(out_array)
add_subdirectory(multi_ret)

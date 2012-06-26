check_all_modules(JSCORE
  GLIB2 REQUIRED glib-2.0
  GOBJECT2 REQUIRED gobject-2.0
  WEBKIT REQUIRED webkitgtk-3.0
  )

add_subdirectory(prop_list)
add_subdirectory(tostring)

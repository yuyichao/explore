project(gdk NONE)

check_all_modules(GDK_MODULES
  GLIB2 REQUIRED glib-2.0
  GOBJECT2 REQUIRED gobject-2.0
  GDK REQUIRED gdk-3.0)

add_subdirectory(keyevent)

project(preload.gtk_accel C)

check_all_modules(GTK_ACCEL
  GTK2 gtk+-2.0)

if(NOT GTK2_FOUND)
  message("preload.gtk_accel disabled")
  return()
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${GTK_ACCEL_INCLUDE_DIRS})
link_directories(${GTK_ACCEL_LINK_DIRS})
add_definitions(${GTK_ACCEL_FLAGS})

set(LIB_GTK_ACCEL_SOURCES
  gtk-accel.c)

add_library(pre-gtk-accel SHARED ${LIB_GTK_ACCEL_SOURCES})
add_executable(gtk-accel
  main.c)
target_link_libraries(pre-gtk-accel dl)
target_link_libraries(gtk-accel ${GTK_ACCEL_LINK})

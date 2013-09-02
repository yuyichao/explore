project(qt C CXX)
find_package(Qt4 REQUIRED COMPONENTS QtCore QtGui QtWebkit QtSql QtNetwork)
add_subdirectory(webplugin)

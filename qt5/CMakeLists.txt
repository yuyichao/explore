project(qt5 C CXX)

find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Widgets REQUIRED)
find_package(Qt5WebKit REQUIRED)
find_package(Qt5WebKitWidgets REQUIRED)
find_package(Qt5Sql REQUIRED)
find_package(Qt5Network REQUIRED)

add_subdirectory(webplugin)

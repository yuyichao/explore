#!/usr/bin/env python

from PyQt4.Qt import *
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtWebKit import *

from os import path as _path
import sys

def main():
    app = QApplication([])
    settings = QWebSettings.globalSettings()
    settings.setAttribute(settings.PluginsEnabled, True)
    widget = QWidget()
    view = QWebView(widget)
    page = view.page()
    page.setPluginFactory(QWebPluginFactory())
    print(page.pluginFactory())
    view.show()
    widget.show()
    view.load(QUrl(_path.abspath(sys.argv[1])))
    app.exec_()

if __name__ == '__main__':
    main()

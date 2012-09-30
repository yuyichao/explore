#!/usr/bin/env python
# -*- coding: utf-8 -*-

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyKDE4.plasma import Plasma
from PyKDE4 import plasmascript

class Plot(QGraphicsWidget):
    def __init__(self, parent, args=None):
        QGraphicsWidget.__init__(self, parent)
        self._buffer = []
    def add_value(self, value):
        value = float(value)
        self._buffer.append(value)
        l = self.geometry().width
        if len(self._buffer) > l:
            self._buffer = self._buffer[-l:]
        update()
    def paint(self, painter, option, widget):
        painter.save()
        geometry = self.geometry()
        w, h = [geometry.width(), geometry.height()]
        print(w, h)
        path = QPainterPath()
        path.moveTo(0, 0)
        path.lineTo(w / 3, h / 2)
        path.lineTo(0, h / 3)
        painter.setBrush(QColor(255, 128, 128, 127))
        painter.setPen(Qt.NoPen)
        painter.drawPath(path)
        painter.restore()

class HelloPython(plasmascript.Applet):
    def __init__(self, parent, args=None):
        self._parent = parent
        plasmascript.Applet.__init__(self, parent)

    def init(self):
        self.setHasConfigurationInterface(False)
        self.resize(125, 125)
        self.setAspectRatioMode(Plasma.Square)
        self.connect_engine()
        self.set_main_layout()

    def set_main_layout(self):
        self._main_layout = QGraphicsLinearLayout(Qt.Horizontal)
        self._main_layout.setContentsMargins(0, 0, 0, 0)
        self._main_layout.setSpacing(5)
        self.setLayout(self._main_layout)
        self._plot = Plot(self._parent)
        self._main_layout.addItem(self._plot)
    @pyqtSignature("dataUpdated(const QString&,"
                   "const Plasma::DataEngine::Data&)")
    def dataUpdated(self, sourceName, data):
        if QString("value") in data:
            value = float(data[QString("value")])

    def connect_engine(self):
        self.obj = obj()
        self.sysengine = self.dataEngine("systemmonitor")
        self.sysengine.connectSource("cpu/system/TotalLoad", self, 100)
        self.sysengine.connectSource("cpu/system/user", self, 1000)

    def _paintInterface(self, painter, option, rect):
        painter.save()
        painter.setPen(Qt.black)
        painter.drawText(rect, Qt.AlignVCenter | Qt.AlignHCenter,
                         "Hello Python!")
        painter.restore()

class obj(QObject):
    @pyqtSignature("dataUpdated(const QString&,"
                   "const Plasma::DataEngine::Data&)")
    def dataUpdated(self, sourceName, data):
        pass

def CreateApplet(parent):
    return HelloPython(parent)

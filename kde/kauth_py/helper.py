#!/usr/bin/env python

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.Qt import *
from PyKDE4.kdecore import *
import sys

class ActionReply(QObject, KAuth.ActionReply):
    pass

def kauthAction(class_name, *arg):
    def _deco(func):
        try:
            name = arg[0]
        except:
            name = func.__name__
        func = pyqtSlot('QVariantMap', name=name,
                        result=ActionReply)(func)
        return func
    return _deco

class KAuthPyHelper(QObject):
    @kauthAction('KAuthPyHelper')
    def action1(self, arg):
        reply = ActionReply()
        reply.setData({"a": "b"})
        return reply

def main():
    exit(KAuth.HelperSupport.helperMain(sys.argv, 'org.yyc.arch.kauthpy',
                                        KAuthPyHelper()))

if __name__ == '__main__':
    main()

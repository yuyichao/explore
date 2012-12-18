#!/usr/bin/env python

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyKDE4.kdecore import *
import sys

def main():
    app = QApplication(sys.argv)
    action1 = KAuth.Action('org.yyc.arch.kauthpy.action1')
    action1.setHelperID('org.yyc.arch.kauthpy')
    action1.setArguments({"c": "d"})
    reply = action1.execute()
    if reply.failed():
        print("Action Failed")
    else:
        print(reply.data())

if __name__ == '__main__':
    main()

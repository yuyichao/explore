#!/usr/bin/env python

from gi.repository import Foo, GObject

class Test1(GObject.Object):
    def __init__(self):
        print(1)
class Test2(GObject.Object):
    def __init__(self, a):
        print(a)

Foo.n(Test1)
Foo.n(Test2)

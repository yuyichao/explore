#!/usr/bin/env python

from gi.repository import Foo, GObject, Gio

class Test1(GObject.Object):
    def __init__(self):
        print(1)
class Test2(GObject.Object):
    def __init__(self, a):
        print(a)

Foo.n(Test1)
#Foo.n(Test2)

import socket

class Socket(Gio.Socket):
    def __init__(self, **kwargs):
        print(self.get_family())
        super().__init__(family=2, **kwargs)
        print(33)

p0, p1 = socket.socketpair()
print(p0.fileno())
s = Foo.n1(Socket, "fd", p0.fileno())
print(s.get_fd())

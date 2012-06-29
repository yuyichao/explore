#!/usr/bin/env python

from gi.repository import Testvm

class AA(Testvm.Object):
    def do_ret_ary(self):
        return (1, 2, 3, 4, 5, 6)
    def do_ret_two(self):
        return (1, 2)

obj = AA()
obj.print()

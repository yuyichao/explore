#!/usr/bin/env python

from gi.repository import Testvm

# class AA(Testvm.Object):
#     def do_do_print1(self):
#         print("overloaded print1")
# class BB(Testvm.Object):
#     def do_do_print2(self):
#         print("overloaded print2")
# class CC(Testvm.Object):
#     def do_wrapper1(self):
#         print("overloaded wrapper1")
# class DD(Testvm.Object):
#     def do_wrapper2(self):
#         print("overloaded wrapper2")

# for c in [AA, BB, CC, DD]:
#     obj = c()
#     obj.print1()
#     obj.wrapper1()
#     obj.real_print2()
#     obj.real_wrapper2()

class EE(Testvm.Object):
    def do_s_method(self):
        print("overloaded do_s_method")
    def s_method(self):
        print("overloaded s_method")

obj = Testvm.Object()
obj.real_s_method()

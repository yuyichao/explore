#!/usr/bin/env python

from gi.repository import Testvm

class AA(Testvm.Object):
#    def do_ret_ary(self):
#        return [1, 2, 3, 4, 5, 6]
#    def do_ret_two(self):
#        return (1, 2)
    def do_arg_buff(self, *args):
        print(args)

obj = AA()
obj.print()
Testvm.print_array(["1", "2", "3", "4", "5", "aaaaaaasdf"])

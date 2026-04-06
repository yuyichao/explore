#!/usr/bin/env python

from amaranth import *
from amaranth.lib import wiring, data
from amaranth.lib.wiring import In, Out

class CAT(wiring.Component):
    A: In(1)
    B: In(1)
    C: In(1)

    O: Out(3)

    def elaborate(self, plat):
        m = Module()

        m.d.comb += self.O.eq(Cat(self.A, self.B, self.C))

        return m

if __name__ == '__main__':
    from amaranth.back import verilog
    m = CAT()
    print(verilog.convert(m, ports=[m.A, m.B, m.C, m.O]))

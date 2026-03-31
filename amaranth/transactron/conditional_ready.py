#

#!/usr/bin/env python

from amaranth import *
from amaranth.lib import wiring
from amaranth.lib.wiring import In, Out

from transactron import TModule, Transaction, Method, def_method

class ConditionalReady(wiring.Component):
    I: Out(1)
    R: Out(1)
    def __init__(self):
        super().__init__()

    def elaborate(self, plat):
        m = TModule()

        false_cond = Signal(1)
        m.d.comb += [false_cond.eq(0),
                     self.R.eq(0)]

        m.d.sync += self.I.eq(~self.I)

        func1 = Method()
        @def_method(m, func1, ready=false_cond)
        def _():
            pass

        with Transaction().body(m):
            with m.If(self.I):
                func1(m)
            m.d.comb += self.R.eq(1)

        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator # , Period
    from transactron import TransactronContextComponent
    p = ConditionalReady()
    m = TransactronContextComponent(p)
    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        for _ in range(10):
            await ctx.tick()
            print(ctx.get(p.I), ctx.get(p.R))
    sim.add_testbench(test)
    sim.run()

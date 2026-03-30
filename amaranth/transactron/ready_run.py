#

#!/usr/bin/env python

from amaranth import *
from amaranth.lib import wiring
from amaranth.lib.wiring import In, Out

from transactron import TModule, Transaction, Method, def_method

class MethodProps(wiring.Component):
    I: Out(1)
    def __init__(self):
        super().__init__()
        self.func1 = Method()
        self.func2 = Method()

    def elaborate(self, plat):
        m = TModule()

        @def_method(m, self.func1, ready=self.I)
        def _():
            pass

        @def_method(m, self.func2)
        def _():
            self.func1(m)

        m.d.sync += self.I.eq(~self.I)

        with Transaction().body(m):
            self.func2(m)

        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator # , Period
    from transactron import TransactronContextComponent
    p = MethodProps()
    m = TransactronContextComponent(p)
    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        await ctx.tick()
        print(ctx.get(p.I), ctx.get(p.func1.ready), ctx.get(p.func2.ready),
              ctx.get(p.func1.run), ctx.get(p.func2.run))
        await ctx.tick()
        print(ctx.get(p.I), ctx.get(p.func1.ready), ctx.get(p.func2.ready),
              ctx.get(p.func1.run), ctx.get(p.func2.run))
    sim.add_testbench(test)
    sim.run()

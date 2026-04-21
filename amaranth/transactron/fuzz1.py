#

from amaranth import *
from amaranth.lib.wiring import Component, In, Out

from transactron import TModule, Transaction, Method, def_method

class Outer(Component):
    ready: In(3)
    run1: Out(3)
    run2: Out(3)

    def elaborate(self, _):
        m = TModule()

        trans1 = Transaction()
        method2 = Method()
        trans3 = Transaction()

        m.d.top_comb += self.run1[0].eq(trans1.run)
        m.d.top_comb += self.run1[1].eq(method2.run)
        m.d.top_comb += self.run1[2].eq(trans3.run)

        with trans1.body(m, ready=self.ready[0]):
            m.d.comb += self.run2[0].eq(1)
            method2(m)

        @def_method(m, method2, ready=self.ready[1])
        def _():
            m.d.comb += self.run2[1].eq(1)
            with trans3.body(m, ready=self.ready[2]):
                m.d.comb += self.run2[2].eq(1)

        m.d.sync += Signal().eq(0)

        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator
    from transactron import TransactronContextElaboratable
    p = Outer()
    m = TransactronContextElaboratable(p)

    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        ctx.set(p.ready, 5)
        await ctx.tick()
        print(ctx.get(p.run1), ctx.get(p.run2))
    sim.add_testbench(test)
    sim.run()

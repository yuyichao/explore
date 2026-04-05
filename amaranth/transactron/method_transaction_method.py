#

from amaranth import *

from transactron import TModule, Transaction, Method, def_method

class Outer(Elaboratable):
    def elaborate(self, _):
        m = TModule()

        inner = Method()
        outer = Method()

        outer_trans_run = Signal(1)

        @def_method(m, inner)
        def _():
            m.d.sync += Print("Inner method")

        # trans_ready = outer.run # This fixes the issue
        trans_ready = C(1)

        @def_method(m, outer, ready=C(0))
        def _():
            m.d.sync += Print("Outer method")
            outer_trans = Transaction()
            with outer_trans.body(m, ready=trans_ready):
                m.d.sync += Print("Outer transaction")
                inner(m)
            m.d.top_comb += outer_trans_run.eq(outer_trans.run)

        m.d.sync += Print(inner.run, outer_trans_run, outer.run)

        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator
    from transactron import TransactronContextElaboratable
    p = Outer()
    m = TransactronContextElaboratable(p)
    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        for _ in range(10):
            await ctx.tick()
    sim.add_testbench(test)
    sim.run()

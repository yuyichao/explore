#

from amaranth import *

from transactron import TModule, Transaction, Method, def_method

from transactron.lib.simultaneous import condition

class Conditional(Elaboratable):
    def elaborate(self, _):
        m = TModule()

        not_runable = Method()
        @def_method(m, not_runable, ready=C(0))
        def _():
            pass

        m.d.sync += Print("Tick")
        with Transaction().body(m):
            m.d.sync += Print("Transaction")
            with condition(m, priority=True) as branch:
                m.d.sync += Print("Condition")
                with branch(1):
                    # not_runable(m)
                    m.d.sync += Print("Branch 0")
                with branch(1):
                    m.d.sync += Print("Branch 1")
                with branch():
                    m.d.sync += Print("Branch 2")

        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator
    from transactron import TransactronContextElaboratable
    p = Conditional()
    m = TransactronContextElaboratable(p)
    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        for _ in range(10):
            await ctx.tick()
    sim.add_testbench(test)
    sim.run()

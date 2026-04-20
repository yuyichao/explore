#

from amaranth import *
from amaranth.lib.wiring import Component, In, Out

from transactron import TModule, Transaction, Method, def_method

class Outer(Component):
    I1: In(1)
    I2: In(1)

    def elaborate(self, _):
        m = TModule()

        method1 = Method()
        method2 = Method()

        @def_method(m, method1)
        def _():
            m.d.sync += Print("Method 1")
            @def_method(m, method2)
            def _():
                m.d.sync += Print("Method 2")

        with Transaction(name="Trans1").body(m, ready=self.I1):
            m.d.sync += Print("Outer transaction 1")
            method1(m)

        with Transaction(name="Trans2").body(m, ready=self.I2):
            m.d.sync += Print("Outer transaction 2")
            method2(m)

        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator
    from transactron import TransactronContextElaboratable
    p = Outer()
    m = TransactronContextElaboratable(p)

    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        print("0, 0")
        await ctx.tick()
        print("0, 1")
        ctx.set(p.I2, 1)
        await ctx.tick()
        print("1, 1")
        ctx.set(p.I1, 1)
        await ctx.tick()
        print("1, 0")
        ctx.set(p.I2, 0)
        await ctx.tick()
    sim.add_testbench(test)
    sim.run()

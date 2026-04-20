#

from amaranth import *
from amaranth.lib.wiring import Component, In, Out

from transactron import TModule, Transaction, Method, def_method

class Outer(Component):
    I: In(1)
    I2: In(1)

    def elaborate(self, _):
        m = TModule()

        method = Method()
        @def_method(m, method)
        def _():
            trans = Transaction(name="InnerTrans")
            with trans.body(m):
                m.d.sync += Print("Inner transaction running")
            m.d.sync += Print("Method runing, trans.run:", trans.run, trans.runnable)

        with Transaction(name="Trans1").body(m, ready=self.I):
            m.d.sync += Print("Outer transaction 1")
            method(m)

        with Transaction(name="Trans2").body(m, ready=self.I2):
            m.d.sync += Print("Outer transaction 2")
            method(m)

        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator
    from transactron import TransactronContextElaboratable
    p = Outer()
    m = TransactronContextElaboratable(p)

    # from amaranth.hdl._ir import *
    # f = Fragment.get(m, None)
    # print(build_netlist(f, [p.I, p.I2]))

    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        ctx.set(p.I, 1)
        for _ in range(3):
            await ctx.tick()
        ctx.set(p.I2, 1)
        for _ in range(3):
            await ctx.tick()
    sim.add_testbench(test)
    sim.run()

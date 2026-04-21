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

        method1 = Method()
        method2 = Method()
        trans3 = Transaction()

        m.d.top_comb += self.run1[0].eq(method1.run)
        m.d.top_comb += self.run1[1].eq(method2.run)
        m.d.top_comb += self.run1[2].eq(trans3.run)

        @def_method(m, method1, nonexclusive=True)
        def _():
            m.d.comb += self.run2[0].eq(1)
            method2(m)
            @def_method(m, method2, ready=self.ready[1])
            def _():
                m.d.comb += self.run2[1].eq(1)
                method1(m)
                with trans3.body(m, ready=self.ready[2]):
                    m.d.comb += self.run2[2].eq(1)

        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator
    from transactron import TransactronContextElaboratable
    p = Outer()
    m = TransactronContextElaboratable(p)

    # from amaranth.back import verilog
    # print(verilog.convert(m, ports=[p.ready, p.run1, p.run2]))

    sim = Simulator(m)
    async def test(ctx):
        ctx.set(p.ready, 4)
        print(ctx.get(p.run1), ctx.get(p.run2))
    sim.add_testbench(test)
    sim.run()

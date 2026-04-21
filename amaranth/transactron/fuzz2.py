#

from amaranth import *
from amaranth.lib.wiring import Component, In, Out

from transactron import TModule, Transaction, Method, def_method

class Outer(Component):
    ready: In(8)
    run: Out(8)

    def elaborate(self, _):
        m = TModule()

        method1 = Method()
        method6 = Method()


        m.d.top_comb += self.run[0].eq(method1.run)
        @def_method(m, method1, ready=self.ready[0])
        def _():
            pass

        trans2 = Transaction()
        m.d.top_comb += self.run[1].eq(trans2.run)
        with trans2.body(m, ready=self.ready[1]):
            trans3 = Transaction()
            m.d.top_comb += self.run[2].eq(trans3.run)
            with trans3.body(m, ready=self.ready[2]):
                method6(m)
            trans4 = Transaction()
            m.d.top_comb += self.run[3].eq(trans4.run)
            with trans4.body(m, ready=self.ready[3]):
                method1(m)
                m.d.top_comb += self.run[5].eq(method6.run)
                @def_method(m, method6, ready=self.ready[5], nonexclusive=True)
                def _():
                    pass
                trans7 = Transaction()
                m.d.top_comb += self.run[6].eq(trans7.run)
                with trans7.body(m, ready=self.ready[6]):
                    method6(m)

            trans8 = Transaction()
            m.d.top_comb += self.run[7].eq(trans8.run)
            with trans8.body(m, ready=self.ready[7]):
                method1(m)
                method6(m)
        trans5 = Transaction()
        m.d.top_comb += self.run[4].eq(trans5.run)
        with trans5.body(m, ready=self.ready[4]):
            method6(m)
            method1(m)

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
        ctx.set(p.ready, 0x6f)
        await ctx.tick()
        print(hex(ctx.get(p.run)))
    sim.add_testbench(test)
    sim.run()

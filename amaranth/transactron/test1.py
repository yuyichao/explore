#!/usr/bin/env python

from amaranth import *
from amaranth.lib import wiring, data
from amaranth.lib.wiring import In, Out
from amaranth.lib.enum import Enum

from transactron import TModule, Transaction, TransactronContextComponent, Method, def_method

class LED(wiring.Component):
    def __init__(self, n):
        super().__init__({'led': Out(n, init=1)})
        self._n = n
        self.up = Method(o=[('end', 1)])
        self.down = Method(o=[('end', 1)])

    def elaborate(self, plat):
        m = TModule()

        @def_method(m, self.up)
        def _():
            m.d.sync += self.led.eq(self.led << 1)
            return dict(end=self.led[self._n - 2])

        @def_method(m, self.down)
        def _():
            m.d.sync += self.led.eq(self.led >> 1)
            return dict(end=self.led[1])

        return m

class WaveDir(Enum, shape=1):
    Up = 0
    Down = 1


class Wave(wiring.Component):
    def __init__(self, n):
        super().__init__({'led': Out(n)})
        self._n = n

    def elaborate(self, plat):
        m = TModule()
        m.submodules.led = led = LED(self._n)
        m.d.comb += self.led.eq(led.led)

        wavedir = Signal(WaveDir, init=WaveDir.Up)

        with Transaction().body(m):
            with m.Switch(wavedir):
                with m.Case(WaveDir.Up):
                    with m.If(led.up(m).end):
                        m.d.sync += wavedir.eq(WaveDir.Down)
                with m.Case(WaveDir.Down):
                    with m.If(led.down(m).end):
                        m.d.sync += wavedir.eq(WaveDir.Up)
        return m

if __name__ == '__main__':
    from amaranth.sim import Simulator # , Period
    m = TransactronContextComponent(Wave(5))
    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        for k in range(100):
            await ctx.tick()
            print(ctx.get(m.led))
    sim.add_testbench(test)
    sim.run()

    from amaranth.back import verilog
    m = TransactronContextComponent(Wave(5))
    print(verilog.convert(m, ports=[m.led]))

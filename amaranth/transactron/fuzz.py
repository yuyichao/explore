#

from amaranth import *
from amaranth.lib.wiring import Component, In, Out
from amaranth.sim import Simulator

from transactron import TModule, Method, def_method, Transaction
from transactron import TransactronContextElaboratable

import pytest
from io import StringIO
import random

class Node:
    def __init__(self, id, ismeth, nonexclusive):
        self.id = id
        self.subnodes = []
        self.ismeth = ismeth
        self.nonexclusive = nonexclusive
        self.called = False
        self.callees = []
        self.runnable = True

    def dump(self):
        return dict(id=self.id,
                    subnodes=[subnode.dump() for subnode in self.subnodes],
                    ismeth=self.ismeth, nonexclusive=self.nonexclusive,
                    callees=[callee.id for callee in self.callees])

    @classmethod
    def load(cls, d):
        nodes = {}
        self = cls._load(d, nodes)
        cls._load_callee(self, d, nodes)
        return self

    @classmethod
    def _load(cls, d, nodes):
        id = d['id']
        self = cls(id, d['ismeth'], d['nonexclusive'])
        nodes[id] = self
        for sd in d['subnodes']:
            self.subnodes.append(cls._load(sd, nodes))
        return self

    @classmethod
    def _load_callee(cls, self, d, nodes):
        for cid in d['callees']:
            self.callees.append(nodes[cid])
        for subnode, sd in zip(self.subnodes, d['subnodes']):
            cls._load_callee(subnode, sd, nodes)

    def reset(self, ready):
        self.called = False
        if self.id != 0:
            self.runnable = ready[self.id - 1]
        for subnode in self.subnodes:
            subnode.reset(ready)

    def propagate_runnable(self):
        changed = False
        for callee in self.callees:
            changed |= callee.propagate_runnable()
        was_runnable = self.runnable
        for callee in self.callees:
            self.runnable &= callee.runnable and not callee.called
        if was_runnable != self.runnable:
            changed = True
        if not self.runnable:
            for subnode in self.subnodes:
                changed |= subnode.runnable
                subnode.runnable = False
        for subnode in self.subnodes:
            changed |= subnode.propagate_runnable()
        return changed

    def propagate_all_runnable(self):
        while self.propagate_runnable():
            pass

    def set_called(self):
        assert not self.called
        assert self.runnable
        if not callee.nonexclusive:
            self.called = True
        for callee in self.callees:
            callee.set_called()

    def set_runnable(self):
        assert self.runnable
        for callee in self.callees:
            callee.set_called()

    def collect_methods(self, methods):
        if self.ismeth:
            methods[self.id] = self
        for subnode in self.subnodes:
            subnode.collect_methods(methods)
        return methods

    def show(self, io, indent):
        if self.id == 0:
            name = "Toplevel"
        elif not self.ismeth:
            name = "Transaction"
        elif self.nonexclusive:
            name = "Method[NE]"
        else:
            name = "Method"
        print(" " * indent + f"{name}<{self.id}>:", file=io)
        for callee in self.callees:
            print(" " * (indent + 2) + f"Method<{callee.id}>()", file=io)
        for subnode in self.subnodes:
            subnode.show(io, indent + 2)

    def __repr__(self):
        io = StringIO()
        self.show(io, 0)
        return io.getvalue()

def gen_rand_node(n, nextracall):
    top = Node(0, False, False)
    nodes = [top]
    methods = []

    for i in range(n):
        parent = random.choice(nodes)
        ismeth = random.randint(0, 1) != 0
        if ismeth:
            nonexclusive = random.randint(0, 1) != 0
        else:
            nonexclusive = False
        new_node = Node(i + 1, ismeth, nonexclusive)
        parent.subnodes.append(new_node)
        nodes.append(new_node)
        if ismeth:
            methods.append(new_node)

    nmethods = len(methods)
    noptions = nmethods * (n - 1)
    options = [False] * noptions

    for i in range(nmethods):
        meth = methods[i]
        callerid = random.randint(1, n - 1)
        options[(callerid - 1) * nmethods + i] = True
        if callerid >= meth.id:
            callerid += 1
        caller = nodes[callerid]
        caller.callees.append(meth)

    for _ in range(nextracall):
        while True:
            callid = random.randint(0, noptions - 1)
            if options[callid]:
                continue
            methid = callid % nmethods
            callerid = (callid // nmethods) + 1
            if callerid >= meth.id:
                callerid += 1
            meth = methods[methid]
            caller = nodes[callerid]
            caller.callees.append(meth)
            break

    return top

class TransactionTester(Component):
    def __init__(self, n, graph):
        super().__init__({'ready': In(n), 'run1': Out(n), 'run2': Out(n)})
        self.graph = graph

    def emit_node(self, m, node, methods):
        for callee_node in node.callees:
            methods[callee_node.id](m)
        for child_node in node.subnodes:
            if child_node.ismeth:
                meth = methods[child_node.id]
                m.d.top_comb += self.run1[child_node.id - 1].eq(meth.run)
                @def_method(m, meth, ready=self.ready[child_node.id - 1])
                def _():
                    m.d.comb += self.run2[child_node.id - 1].eq(1)
                    self.emit_node(m, child_node, methods)
            else:
                trans = Transaction()
                m.d.top_comb += self.run1[child_node.id - 1].eq(trans.run)
                with trans.body(m, ready=self.ready[child_node.id - 1]):
                    m.d.comb += self.run2[child_node.id - 1].eq(1)
                    self.emit_node(m, child_node, methods)

    def elaborate(self, _):
        m = TModule()

        methods = {}
        for (id, meth_node) in self.graph.collect_methods({}).items():
            methods[id] = Method()

        self.emit_node(m, self.graph, methods)

        m.d.sync += Signal().eq(0)

        return m


@pytest.mark.parametrize("n", [3])
@pytest.mark.parametrize("nextracall", [0])
@pytest.mark.parametrize("dummy", range(100))
def test_rand(n, nextracall, dummy):
    graph = gen_rand_node(n, nextracall)

    p = TransactionTester(n, graph)
    m = TransactronContextElaboratable(p)
    try:
        Fragment.get(m, None)
    except:
        return

    print(graph)
    print(graph.dump())
    p = TransactionTester(n, graph)
    m = TransactronContextElaboratable(p)

    sim = Simulator(m)
    sim.add_clock(1e-6)
    async def test(ctx):
        for ready in range(2**n):
            ctx.set(p.ready, ready)
            await ctx.tick()
            run1 = ctx.get(p.run1)
            run2 = ctx.get(p.run2)
            print(hex(ready), hex(run1), hex(run2))
            assert run1 == run2

    sim.add_testbench(test)
    sim.run()

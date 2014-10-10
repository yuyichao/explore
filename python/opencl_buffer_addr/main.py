#!/usr/bin/env python

import pyopencl as cl
import numpy as np

def main():
    ctx = cl.create_some_context()
    queue = cl.CommandQueue(ctx)
    mf = cl.mem_flags
    buf = cl.Buffer(ctx, mf.READ_ONLY, 1000)
    buf2 = cl.Buffer(ctx, mf.READ_WRITE, 8)
    prg = cl.Program(ctx, """
    __kernel void
    get_addr(__global const int *in, __global long *out)
    {
        *out = (long)in;
    }
    """).build()

    knl = prg.get_addr
    knl.set_args(buf, buf2)
    cl.enqueue_task(queue, knl)

    b = np.empty([1], dtype=np.int64)
    cl.enqueue_copy(queue, b, buf2).wait()
    print(b[0])

    prg = cl.Program(ctx, """
    __kernel void
    get_addr(__global const int *in, __global long *out)
    {
        *out = (long)in;
    }
    """).build()
    knl = prg.get_addr
    knl.set_args(buf, buf2)
    cl.enqueue_task(queue, knl)

    b = np.empty([1], dtype=np.int64)
    cl.enqueue_copy(queue, b, buf2).wait()
    print(b[0])

if __name__ == '__main__':
    main()

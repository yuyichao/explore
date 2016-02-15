// clang -O3 -fPIC -std=c11 --target=armv7l-linux-gnueabihf atomics.c -S -o atomics_armv7l.s
// clang -O3 -fPIC -std=c11 --target=aarch64-linux-gnu atomics.c -S -o atomics_aarch64.s
// clang -O3 -fPIC -std=c11 --target=x86_64-linux-gnu atomics.c -S -o atomics_x64.s
// clang -O3 -fPIC -std=c11 --target=i686-linux-gnu atomics.c -S -o atomics_i686.s

#include <stdatomic.h>

// opaque function to make sure the compiler cannot optimize multiple atomic
// store/load out
void g(void);

atomic_int a = ATOMIC_VAR_INIT(0);
volatile int b = 0;

void f(void)
{
    // Make sure the compiler load &a to a register so that it won't mess
    // up what we want to see in the codegen
    atomic_store_explicit(&a, 0, memory_order_relaxed);
    g();
    g();
    // The actual atomic instruction starts after two calls of g
    atomic_store_explicit(&a, 0, memory_order_seq_cst);
    g();
    atomic_store_explicit(&a, 0, memory_order_release);
    g();
    atomic_store_explicit(&a, 0, memory_order_relaxed);
    g();

    // Make sure the compiler load &b to a register so that it won't mess
    // up what we want to see in the codegen
    b = 1;
    g();
    g();
    // The actual atomic instruction starts after two calls of g
    b = atomic_load_explicit(&a, memory_order_seq_cst);
    g();
    b = atomic_load_explicit(&a, memory_order_acquire);
    g();
    b = atomic_load_explicit(&a, memory_order_relaxed);
    g();
}

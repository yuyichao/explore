// Check what kind of barrier an atomic_store and an atomic_load is.

#include <stdatomic.h>

atomic_int a = ATOMIC_VAR_INIT(1);
int b = 0;
int c = 0;

void f_store_seq_cst(void)
{
    b = 2;
    atomic_store_explicit(&a, 1, memory_order_seq_cst);
    b = 3;
}

void f_store_release(void)
{
    b = 2;
    atomic_store_explicit(&a, 1, memory_order_release);
    b = 3;
}

void f_load_seq_cst(void)
{
    b = 2;
    c = atomic_load_explicit(&a, memory_order_seq_cst);
    b = 1;
}

void f_load_acquire(void)
{
    b = 2;
    c = atomic_load_explicit(&a, memory_order_acquire);
    b = 1;
}

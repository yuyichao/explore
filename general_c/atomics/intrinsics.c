// gcc -Wpedantic -Wall -Wextra -O3 -std=c99 -fPIC intrinsics.c -S -o -

// opaque function to make sure the compiler cannot optimize multiple atomic
// store/load out
void g(void);

int a = 0;
volatile int b = 0;

void f(void)
{
    // Make sure the compiler load &a to a register so that it won't mess
    // up what we want to see in the codegen
    __atomic_store_n(&a, 0, __ATOMIC_RELAXED);
    g();
    g();
    // The actual atomic instruction starts after two calls of g
    __atomic_store_n(&a, 0, __ATOMIC_SEQ_CST);
    g();
    __atomic_store_n(&a, 0, __ATOMIC_RELEASE);
    g();
    __atomic_store_n(&a, 0, __ATOMIC_RELAXED);
    g();

    // Make sure the compiler load &b to a register so that it won't mess
    // up what we want to see in the codegen
    b = 1;
    g();
    g();
    // The actual atomic instruction starts after two calls of g
    b = __atomic_load_n(&a, __ATOMIC_SEQ_CST);
    g();
    b = __atomic_load_n(&a, __ATOMIC_ACQUIRE);
    g();
    b = __atomic_load_n(&a, __ATOMIC_RELAXED);
    g();
}

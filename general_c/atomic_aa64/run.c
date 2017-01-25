//

#include <stdint.h>
#include <time.h>
#include <stdio.h>

double gettime(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec + t.tv_nsec * 1e-9;
}

__attribute__((noinline)) intptr_t f1(intptr_t *a, intptr_t *b)
{
    asm volatile ("" ::: "memory");
    intptr_t va = __atomic_load_n(a, __ATOMIC_ACQUIRE);
    intptr_t vb = *b;
    return va + vb;
}

__attribute__((noinline)) intptr_t f2(intptr_t *a, intptr_t *b)
{
    asm volatile ("" ::: "memory");
    intptr_t va = *a;
    intptr_t vb = *b;
    return va + vb;
}

__attribute__((noinline)) intptr_t f3(intptr_t *a, intptr_t *b)
{
    asm volatile ("" ::: "memory");
    intptr_t va = *a;
    asm volatile ("dmb ishld" ::: "memory");
    intptr_t vb = *b;
    return va + vb;
}

__attribute__((noinline)) intptr_t f4(intptr_t *a, intptr_t *b)
{
    asm volatile ("" ::: "memory");
    intptr_t va = *a;
    asm volatile ("dmb ish" ::: "memory");
    intptr_t vb = *b;
    return va + vb;
}

__attribute__((noinline)) intptr_t f5(intptr_t *a, intptr_t *b)
{
    asm volatile ("" ::: "memory");
    intptr_t va = *a;
    asm volatile ("dmb sy" ::: "memory");
    intptr_t vb = *b;
    return va + vb;
}

__attribute__((noinline))
void benchmark(const char *name, intptr_t (*fptr)(intptr_t *a, intptr_t *b),
               intptr_t *a, intptr_t *b)
{
    double t1 = gettime();
    for (int i = 0;i < 1000000000;i++)
        fptr(a, b);
    double t2 = gettime();
    printf("%s: %f\n", name, t2 - t1);
}

int main()
{
    intptr_t a = 1;
    intptr_t b = 1;
    benchmark("acquire", f1, &a, &b);
    benchmark("none", f2, &a, &b);
    benchmark("dmb ishld", f3, &a, &b);
    benchmark("dmb ish", f4, &a, &b);
    benchmark("dmb sy", f5, &a, &b);
    return 0;
}

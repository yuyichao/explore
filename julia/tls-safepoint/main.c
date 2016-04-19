//

#include <stdio.h>
#include <alloca.h>
#include <stdint.h>
#include <time.h>

typedef struct _stack {
    size_t n;
    struct _stack *parent;
    void *ptrs[];
} stack;

typedef struct {
    stack *sp;
    volatile size_t *load;
    int32_t state;
} tlsbuff;

__attribute__((noinline)) tlsbuff *get_tls(void)
{
    static size_t v;
    static __thread __attribute__((tls_model("local-exec"))) tlsbuff buff = {
        NULL, &v, 0
    };
    return &buff;
}

__attribute__((noinline)) void f0(void)
{
    static tlsbuff buff0 = {NULL, NULL, 0};
    tlsbuff *buff = &buff0;
    stack *s = (stack*)alloca(sizeof(void*) * 3);
    s->n = 1;
    s->ptrs[0] = NULL;
    s->parent = buff->sp;
    buff->sp = s;
}

__attribute__((noinline)) void f1(void)
{
    tlsbuff *buff = get_tls();
    volatile size_t *load = buff->load;
    stack *s = (stack*)alloca(sizeof(void*) * 3);
    s->n = 1;
    s->ptrs[0] = NULL;
    s->parent = buff->sp;
    __atomic_store_n(&buff->state, 1, __ATOMIC_RELEASE);
    size_t dummy = *load;
    buff->sp = s;
    __atomic_store_n(&buff->state, 0, __ATOMIC_RELEASE);
    dummy = *load;
    (void)dummy;
}

__attribute__((noinline)) void f2(void)
{
    tlsbuff *buff = get_tls();
    static volatile size_t val;
    volatile size_t *load = &val;
    stack *s = (stack*)alloca(sizeof(void*) * 3);
    s->n = 1;
    s->ptrs[0] = NULL;
    s->parent = buff->sp;
    __atomic_store_n(&buff->state, 1, __ATOMIC_RELEASE);
    size_t dummy = *load;
    buff->sp = s;
    __atomic_store_n(&buff->state, 0, __ATOMIC_RELEASE);
    dummy = *load;
    (void)dummy;
}

static uint64_t time2u64(const struct timespec *time)
{
    return ((uint64_t)time->tv_sec) * 1000000000 + time->tv_nsec;
}

static __attribute__((noinline)) uint64_t gettime_ns(clockid_t clk_id)
{
    struct timespec t;
    clock_gettime(clk_id, &t);
    return time2u64(&t);
}

__attribute__((noinline)) uint64_t time0(size_t n)
{
    uint64_t start = gettime_ns(CLOCK_MONOTONIC);
    for (size_t i = 0;i < n;i++) {
        f0();
    }
    uint64_t end = gettime_ns(CLOCK_MONOTONIC);
    return end - start;
}

__attribute__((noinline)) uint64_t time1(size_t n)
{
    uint64_t start = gettime_ns(CLOCK_MONOTONIC);
    for (size_t i = 0;i < n;i++) {
        f1();
    }
    uint64_t end = gettime_ns(CLOCK_MONOTONIC);
    return end - start;
}

__attribute__((noinline)) uint64_t time2(size_t n)
{
    uint64_t start = gettime_ns(CLOCK_MONOTONIC);
    for (size_t i = 0;i < n;i++) {
        f2();
    }
    uint64_t end = gettime_ns(CLOCK_MONOTONIC);
    return end - start;
}

void runall(void)
{
    size_t n = 1000000000UL;
    uint64_t t0 = time0(n);
    uint64_t t1 = time1(n);
    uint64_t t2 = time2(n);
    printf("%f, %f, %f\n", t0 * 1.0 / n, t1 * 1.0 / n, t2 * 1.0 / n);
}

int main()
{
    runall();
    runall();
    runall();
    return 0;
}

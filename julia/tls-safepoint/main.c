//

#include <stdio.h>
#include <alloca.h>
#include <stdint.h>
#include <time.h>

void safepoint_load(volatile int32_t *load)
{
    __atomic_signal_fence(__ATOMIC_SEQ_CST);
    int32_t dummy = *load;
    __atomic_signal_fence(__ATOMIC_SEQ_CST);
    (void)dummy;
}

typedef struct _stack {
    size_t n;
    struct _stack *parent;
    void *ptrs[];
} stack;

typedef struct {
    stack *sp;
    volatile int32_t *load;
    volatile int32_t state;
} tlsbuff;

__attribute__((noinline)) tlsbuff *get_tls(void)
{
    static int32_t v;
    static __thread __attribute__((tls_model("local-exec"))) tlsbuff buff = {
        NULL, &v, 0
    };
    return &buff;
}

static tlsbuff buff0 = {NULL, NULL, 0};

__attribute__((noinline)) void work(void)
{
    for (volatile int i = 0;i < 10;i++) {
        int32_t dummy = buff0.state;
        (void)dummy;
        stack *dummy2 = *(stack *volatile*)&buff0.sp;
        (void)dummy2;
        __asm__ volatile ("" ::: "memory");
    }
}

__attribute__((noinline)) void f0(void)
{
    tlsbuff *buff = &buff0;
    // gc_push
    stack *s = (stack*)alloca(sizeof(void*) * 3);
    s->n = 1;
    s->ptrs[0] = NULL;
    s->parent = buff->sp;
    buff->sp = s;

    work();

    // gc_pop
    buff->sp = s->parent;
}

__attribute__((noinline)) void f1(void)
{
    tlsbuff *buff = get_tls();
    volatile int32_t *load = buff->load;
    stack *s = (stack*)alloca(sizeof(void*) * 3);
    s->n = 1;
    s->ptrs[0] = NULL;
    s->parent = buff->sp;
    __atomic_store_n(&buff->state, 1, __ATOMIC_RELEASE);
    safepoint_load(load);
    buff->sp = s;
    __atomic_store_n(&buff->state, 0, __ATOMIC_RELEASE);

    work();

    // gc_pop
    __atomic_store_n(&buff->state, 1, __ATOMIC_RELEASE);
    safepoint_load(load);
    buff->sp = s->parent;
    __atomic_store_n(&buff->state, 0, __ATOMIC_RELEASE);
}

__attribute__((noinline)) void f2(void)
{
    tlsbuff *buff = get_tls();
    static volatile int32_t val;
    volatile int32_t *load = &val;
    stack *s = (stack*)alloca(sizeof(void*) * 3);
    s->n = 1;
    s->ptrs[0] = NULL;
    s->parent = buff->sp;
    __atomic_store_n(&buff->state, 1, __ATOMIC_RELEASE);
    safepoint_load(load);
    buff->sp = s;
    __atomic_store_n(&buff->state, 0, __ATOMIC_RELEASE);

    work();

    // gc_pop
    __atomic_store_n(&buff->state, 1, __ATOMIC_RELEASE);
    safepoint_load(load);
    buff->sp = s->parent;
    __atomic_store_n(&buff->state, 0, __ATOMIC_RELEASE);
}

__attribute__((noinline)) void f3(void)
{
    tlsbuff *buff = get_tls();
    volatile int32_t *load = buff->load;
    stack *s = (stack*)alloca(sizeof(void*) * 3);
    s->n = 1;
    s->ptrs[0] = NULL;
    s->parent = buff->sp;
    buff->state = 1;
    safepoint_load(load);
    buff->sp = s;
    buff->state = 0;

    work();

    // gc_pop
    buff->state = 1;
    safepoint_load(load);
    buff->sp = s->parent;
    buff->state = 0;
}

__attribute__((noinline)) void f4(void)
{
    tlsbuff *buff = get_tls();
    static volatile int32_t val;
    volatile int32_t *load = &val;
    stack *s = (stack*)alloca(sizeof(void*) * 3);
    s->n = 1;
    s->ptrs[0] = NULL;
    s->parent = buff->sp;
    buff->state = 1;
    safepoint_load(load);
    buff->sp = s;
    buff->state = 0;

    work();

    // gc_pop
    buff->state = 1;
    safepoint_load(load);
    buff->sp = s->parent;
    buff->state = 0;
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

__attribute__((noinline)) uint64_t time3(size_t n)
{
    uint64_t start = gettime_ns(CLOCK_MONOTONIC);
    for (size_t i = 0;i < n;i++) {
        f3();
    }
    uint64_t end = gettime_ns(CLOCK_MONOTONIC);
    return end - start;
}

__attribute__((noinline)) uint64_t time4(size_t n)
{
    uint64_t start = gettime_ns(CLOCK_MONOTONIC);
    for (size_t i = 0;i < n;i++) {
        f4();
    }
    uint64_t end = gettime_ns(CLOCK_MONOTONIC);
    return end - start;
}

void runall(void)
{
    size_t n = 46000000UL;
    uint64_t t0 = time0(n);
    uint64_t t1 = time1(n);
    uint64_t t2 = time2(n);
    uint64_t t3 = time3(n);
    uint64_t t4 = time4(n);
    printf("%f, %f, %f, %f, %f\n", t0 * 4.6 / n, t1 * 4.6 / n,
           t2 * 4.6 / n, t3 * 4.6 / n, t4 * 4.6 / n);
}

int main()
{
    runall();
    runall();
    runall();
    return 0;
}

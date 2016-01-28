//

#include <time.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>

static uint64_t time2u64(const struct timespec *time)
{
    return ((uint64_t)time->tv_sec) * 1000000000 + time->tv_nsec;
}

static inline uint64_t gettime_ns(clockid_t clk_id)
{
    struct timespec t;
    clock_gettime(clk_id, &t);
    return time2u64(&t);
}

static inline uint64_t getres_ns(clockid_t clk_id)
{
    struct timespec t;
    clock_getres(clk_id, &t);
    return time2u64(&t);
}

static uint64_t measure_res(clockid_t clk_id)
{
    uint64_t res = (uint64_t)-1;
    uint64_t prev_t = gettime_ns(clk_id);
    for (int i = 0;i < 1000000;i++) {
        for (int j = 0;j < 100;j++) {
            uint64_t t = gettime_ns(clk_id);
            uint64_t diff_t = t - prev_t;
            if (t > prev_t) {
                if (diff_t < res)
                    res = diff_t;
                prev_t = t;
                break;
            } else {
                prev_t = t;
            }
        }
    }
    return res;
}

static void test_clock(clockid_t clk_id)
{
    struct timespec t;
    if (clock_gettime(clk_id, &t) == -1) {
        printf("Unsupported.\n");
        return;
    }
    uint64_t start = gettime_ns(CLOCK_MONOTONIC);
    int n = 1000000;
    for (int i = 0;i < n;i++)
        gettime_ns(clk_id);
    uint64_t end = gettime_ns(CLOCK_MONOTONIC);
    uint64_t res = getres_ns(clk_id);
    uint64_t res_m = measure_res(clk_id);
    printf("Time: %.1f; Resolution: %" PRIu64 "; Resolution measured: %" PRIu64 "\n", (double)(end - start) / (double)n, res, res_m);
}

#define test_clock(name) do {                   \
        printf("%s: ", #name);                  \
        test_clock(name);                       \
    } while (0)

static __attribute__((noinline)) uint64_t rdtsc(void)
{
    unsigned hi, lo;
    __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
    __asm__ __volatile__ ("" : : : "memory");
    return ((uint64_t)lo) | (((uint64_t)hi) << 32);
}

static uint64_t measure_res_rdtsc()
{
    uint64_t res = (uint64_t)-1;
    uint64_t prev_t = rdtsc();
    for (int i = 0;i < 1000000;i++) {
        for (int j = 0;j < 100;j++) {
            uint64_t t = rdtsc();
            uint64_t diff_t = t - prev_t;
            if (t > prev_t) {
                if (diff_t < res)
                    res = diff_t;
                prev_t = t;
                break;
            } else {
                prev_t = t;
            }
        }
    }
    return res;
}

static void test_rdtsc(void)
{
    printf("rdtsc: ");
    uint64_t start = gettime_ns(CLOCK_MONOTONIC);
    int n = 1000000;
    for (int i = 0;i < n;i++)
        rdtsc();
    uint64_t end = gettime_ns(CLOCK_MONOTONIC);
    uint64_t res_m = measure_res_rdtsc();
    printf("Time: %.1f; Resolution measured: %" PRIu64 "\n", (double)(end - start) / (double)n, res_m);
}

int main()
{
    test_clock(CLOCK_REALTIME);
    test_clock(CLOCK_REALTIME_COARSE);
    test_clock(CLOCK_MONOTONIC);
    test_clock(CLOCK_MONOTONIC_COARSE);
    test_clock(CLOCK_MONOTONIC_RAW);
    test_clock(CLOCK_BOOTTIME);
    test_clock(CLOCK_PROCESS_CPUTIME_ID);
    test_clock(CLOCK_THREAD_CPUTIME_ID);
    test_rdtsc();
    return 0;
}

#include <iostream>
#include <ctime>
#include <stdlib.h>
// #include <omp.h>

#define SIZE (1024 * 1024)
#define PARALLEL_NUMBER 16
#define REPEAT_NUMBER (1024 * 1024)
#define LOOP_NUMBER 8 * 1024

template<typename T>
T *cacheline_alloc(size_t nele)
{
    void *ptr;
    posix_memalign(&ptr, 64, nele * sizeof(T));
    return (T*)ptr;
}

double time()
{
    struct timespec sj;
    clock_gettime(CLOCK_MONOTONIC, &sj);
    return (double)sj.tv_sec + 1e-9 * (double)sj.tv_nsec;
}

__attribute__((noinline)) void kernel(float a, float *data_a, float *data_b)
{
    data_a = (float*)__builtin_assume_aligned(data_a, 64);
    data_b = (float*)__builtin_assume_aligned(data_b, 64);
#pragma omp parallel for
    for (int p = 0; p < PARALLEL_NUMBER; ++p) {
        int offset = p * LOOP_NUMBER;
        float *da = data_a + offset;
        float *db = data_b + offset;
        for (int r = 0; r < REPEAT_NUMBER; ++r) {
            for (int i = 0; i < LOOP_NUMBER; ++i) {
                da[i] = a * da[i] + db[i];
            }
        }
    }
}

void test(float *data_a, float *data_b)
{
    for (int i = 0; i < LOOP_NUMBER; ++i)
        data_a[i] = 3.21 * i;
    for (int i = 0; i < LOOP_NUMBER; ++i)
        data_b[i] = 1.2345 * i;
    float a = rand();
    double tstart = time();
    kernel(a, data_a, data_b);
    double tstop = time();
    std::cout << "alignment(64), Secs = " << (tstop - tstart)
              << ", Flops/sec = "
              << ((double)PARALLEL_NUMBER * REPEAT_NUMBER * LOOP_NUMBER *
                  2 / (tstop - tstart))
              << std::endl;
}


int main ()
{
    auto data_a = cacheline_alloc<float>(SIZE);
    auto data_b = cacheline_alloc<float>(SIZE);
    std::cout << data_a << std::endl
              << data_b << std::endl;
    test(data_a, data_b);
    return 0;
}

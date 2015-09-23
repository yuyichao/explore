//

#include <stddef.h>
#include <stdint.h>
#include <cilk/cilk.h>

void
copy_soa2aos(float *__restrict__ src, float *__restrict__ dest1,
             float *__restrict__ dest2, size_t len)
{
    src = (float*)__builtin_assume_aligned(src, 16);
    dest1 = (float*)__builtin_assume_aligned(dest1, 16);
    dest2 = (float*)__builtin_assume_aligned(dest2, 16);
    for (size_t i = 0;i < len;i++) {
        dest1[i] = src[i * 2];
        dest2[i] = src[i * 2 + 1];
    }
}

void
copy_soa2aos_cilk(float *__restrict__ src, float *__restrict__ dest1,
                  float *__restrict__ dest2, size_t len)
{
    src = (float*)__builtin_assume_aligned(src, 16);
    dest1 = (float*)__builtin_assume_aligned(dest1, 16);
    dest2 = (float*)__builtin_assume_aligned(dest2, 16);
    cilk_for (size_t i = 0;i < len;i++) {
        dest1[i] = src[i * 2];
        dest2[i] = src[i * 2 + 1];
    }
}

void
copy_soa2aos_omp(float *__restrict__ src, float *__restrict__ dest1,
                 float *__restrict__ dest2, size_t len)
{
    src = (float*)__builtin_assume_aligned(src, 16);
    dest1 = (float*)__builtin_assume_aligned(dest1, 16);
    dest2 = (float*)__builtin_assume_aligned(dest2, 16);
#pragma omp parallel for
    for (size_t i = 0;i < len;i++) {
        dest1[i] = src[i * 2];
        dest2[i] = src[i * 2 + 1];
    }
}

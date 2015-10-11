// clang -mavx2 -Ofast -Wall -Wextra -S test.c -emit-llvm

#include <stddef.h>

void
fill_simd1(float *__restrict__ A, size_t size, const float *__restrict__ v)
{
    for (size_t i = 0;i < size;i++) {
        A[i] = *v;
    }
}

void
fill_simd2(float *__restrict__ A, size_t size, const double *__restrict__ v)
{
    for (size_t i = 0;i < size;i++) {
        A[i] = *v;
    }
}

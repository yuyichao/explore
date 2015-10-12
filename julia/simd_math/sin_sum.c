// gcc -fPIC -lmvec -fopenmp -shared -Wall -Wextra -mavx2 -fPIC -Ofast sin_sum.c -o libsin_sum_gcc.so
// clang -fPIC -lmvec -fopenmp -shared -Wall -Wextra -mavx2 -fPIC -Ofast sin_sum.c -o libsin_sum_clang.so

#include <math.h>
#include <stddef.h>

float
sum_sin(const float *__restrict__ p, size_t len)
{
    float s = 0;
#pragma omp simd
    for (size_t i = 0;i < len;i++) {
        s += sinf(p[i]);
    }
    return s;
}

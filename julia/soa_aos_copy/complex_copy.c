//

#include <stddef.h>
#include <stdint.h>

void
copy_soa2aos(float *__restrict__ src, float *__restrict__ dest1,
             float *__restrict__ dest2, size_t len)
{
/* #pragma omp simd */
    for (size_t i = 0;i < len;i++) {
        dest1[i] = src[i * 2];
        dest2[i] = src[i * 2 + 1];
    }
}

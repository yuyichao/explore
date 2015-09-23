//

#include <stddef.h>
#include <stdint.h>

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
copy_aos2soa(float *__restrict__ dest, float *__restrict__ src1,
             float *__restrict__ src2, size_t len)
{
    dest = (float*)__builtin_assume_aligned(dest, 16);
    src1 = (float*)__builtin_assume_aligned(src1, 16);
    src2 = (float*)__builtin_assume_aligned(src2, 16);
    for (size_t i = 0;i < len;i++) {
        dest[i * 2] = src1[i];
        dest[i * 2 + 1] = src2[i];
    }
}

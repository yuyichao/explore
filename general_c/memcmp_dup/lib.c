#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void
my_memcpy(void *dest, void *src, size_t size)
{
    memcpy(dest, src, size);
}

void
my_memcpy2(void *dest, void *src, size_t size)
{
    if (memcmp(dest, src, size))
        memcpy(dest, src, size);
}

void*
my_memset(void *dest, void *src, size_t size)
{
    dest = realloc(dest, size);
    memcpy(dest, src, size);
    return dest;
}

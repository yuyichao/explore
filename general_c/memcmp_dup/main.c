#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "lib.h"

#define BUFF1 "jjjjjjjkkjjjjjjjjjjjlllllllllllllllljjjjjjjjjjjjjjjj"
#define BUFF2 "jjjjjjjkkjajslkdf;aldsfajjjjjjjjjjaldskfa;lsdflllj;l"    \
    "jjjjjjjkkjajslkdf;aldsfajjjjjjjjjjaldskfa;lsdflllj;l"              \
    "jjjjjjjkkjajslkdf;aldsfajjjjjjjjjjaldskfa;lsdflllj;l"              \
    "jjjjjjjkkjajslkdfalksdj;flkajdsjjjaldskfa;lsdflllj;l"              \
    "jjjjjjjkkjajslkdf;aldsfajjjjjjjjjjaldskfa;lsdflllj;l"              \
    "jjjjjjjkkjajslkdfalksdj;flkajdsjjjaldskfa;lsdflllj;l"              \
    "jjjjjjjkkjajslkdf;aldsfajjjjjjjjjjaldskfa;lsdflllj;l"              \
    "jjjjkasdfjajslkdf;aldsfajjjjjjjjjjaldskfa;lsdflllj;l"

#define BUFF3 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1 \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1         \
    BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF1 BUFF2 BUFF1 BUFF2 BUFF1

#define N 1000000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

int
main()
{
    int i;
    struct timespec start, end;
    long long t;
    size_t len;
    void *p = NULL;
    char *src = NULL;
    char dest[] = BUFF3;
    src = BUFF1;
    len = strlen(BUFF1) + 1;
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        my_memcpy(dest, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcpy:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        my_memcpy2(dest, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcmp+memcpy:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        p = my_memset(p, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc+memcpy:\n\t %lld\n", __func__, t);
    printf("\n");

    src = BUFF2;
    len = strlen(BUFF2) + 1;
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        my_memcpy(dest, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcpy:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        my_memcpy2(dest, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcmp+memcpy:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        p = my_memset(p, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc+memcpy:\n\t %lld\n", __func__, t);
    printf("\n");

    src = BUFF3;
    len = strlen(BUFF3) + 1;
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        my_memcpy(dest, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcpy:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        my_memcpy2(dest, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcmp+memcpy:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        p = my_memset(p, src, len);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc+memcpy:\n\t %lld\n", __func__, t);
    printf("\n");

    return 0;
}

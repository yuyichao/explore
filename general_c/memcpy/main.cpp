#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include "lib.h"

#define N 10000000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

int _global_;

int
main()
{
    unsigned int i;
    struct timespec start, end;
    long long t;
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        _global_ = simple_return(_global_);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, simple:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        _global_ = memcpy_return(_global_);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcpy:\n\t %lld\n", __func__, t);

    float f = 1.23;

    printf("%s, %d\n", __func__, float_to_int1(f));
    printf("%s, %d\n", __func__, float_to_int2(f));
    printf("%s, %d\n", __func__, float_to_int3(f));

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        _global_ = float_to_int3(f);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcpy2:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        _global_ = float_to_int1(f);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, memcpy:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        _global_ = float_to_int2(f);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, cast:\n\t %lld\n", __func__, t);

    return 0;
}

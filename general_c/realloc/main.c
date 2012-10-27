#include <stdlib.h>
#include <stdio.h>
#include <time.h>

static int sizes[] = { 4, 40, 400, 80, 8, 80, 800, 160, 16 };
#define N 100000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

int
main()
{
    void *p = NULL;
    int i, j;
    struct timespec start, end;
    long long t;
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            if (p)
                free(p);
            p = malloc(sizes[j]);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, free+malloc:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            p = realloc(p, sizes[j]);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc:\n\t %lld\n", __func__, t);
    printf("\n");

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            if (p)
                free(p);
            p = malloc(sizes[j] * 16 * 1024);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, free+malloc:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            p = realloc(p, sizes[j] * 16 * 1024);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc:\n\t %lld\n", __func__, t);
    printf("\n");

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            p = realloc(p, sizes[j] * 1024 * 1024);
            p = realloc(p, sizes[j]);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc*2:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            if (p)
                free(p);
            p = malloc(sizes[j] * 1024 * 1024);
            if (p)
                free(p);
            p = malloc(sizes[j]);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, free+malloc*2:\n\t %lld\n", __func__, t);
    printf("\n");

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            p = realloc(p, sizes[j] * 1024 * 1024);
            p = realloc(p, sizes[j] * 1024);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc*2:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            if (p)
                free(p);
            p = malloc(sizes[j] * 1024 * 1024);
            if (p)
                free(p);
            p = malloc(sizes[j] * 1024);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, free+malloc*2:\n\t %lld\n", __func__, t);
    printf("\n");

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            p = realloc(p, sizes[j] * 1024 * 1024);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < sizeof(sizes) / sizeof(int);j++) {
            if (p)
                free(p);
            p = malloc(sizes[j] * 1024 * 1024);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, free+malloc:\n\t %lld\n", __func__, t);
    return 0;
}

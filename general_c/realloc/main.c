#include <stdlib.h>
#include <stdio.h>
#include <time.h>

static int sizes[] = { 4, 40, 400, 80, 8, 80, 800, 160, 16 };
#define N 100000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC
void *p = NULL;

#define PAGE_COUNT (1024 * 16)
#define PAGE_SIZE (1024 * 8)

void *pages[PAGE_COUNT];

#define PAGE_INIT (PAGE_COUNT * 2 / 3)

int
main()
{
    unsigned int i, j;
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
    printf("\n");

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < PAGE_COUNT;i++) {
        pages[i] = malloc(PAGE_SIZE);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, pages:\n\t %lld\n", __func__, t);
    for (i = 0;i < PAGE_COUNT;i++) {
        free(pages[i]);
    }

    clock_gettime(CLOCK_ID, &start);
    p = realloc(p, PAGE_INIT * PAGE_SIZE);
    for (i = PAGE_INIT + 1;i <= PAGE_COUNT;i++) {
        p = realloc(p, PAGE_SIZE * i);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc:\n\t %lld\n", __func__, t);
    free(p);

    clock_gettime(CLOCK_ID, &start);
    p = malloc(PAGE_COUNT * PAGE_SIZE * 3);
    p = realloc(p, PAGE_COUNT * PAGE_SIZE);
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, shrink:\n\t %lld\n", __func__, t);

    free(p);
    return 0;
}

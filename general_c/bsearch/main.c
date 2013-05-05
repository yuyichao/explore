#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "lib.h"

#define N 10000000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

#define ITEM_LEN (40)

void
time_search_b(Item *items, size_t len, int key)
{
    struct timespec start, end;
    long long t;
    int i;
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        search_b(items, len, key);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, search_b:\n\t %lld\n", __func__, t);
}

void
time_search_i(Item *items, size_t len, int key)
{
    struct timespec start, end;
    long long t;
    int i;
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        search_i(items, len, key);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, search_i:\n\t %lld\n", __func__, t);
}

int
main()
{
    Item *items = new_items(ITEM_LEN);

    struct timespec start, end;
    long long t_b, t_i;
    clock_gettime(CLOCK_ID, &start);
    time_search_b(items, ITEM_LEN, ITEM_LEN / 5);
    time_search_b(items, ITEM_LEN, ITEM_LEN * 2 / 5);
    time_search_b(items, ITEM_LEN, ITEM_LEN * 3 / 5);
    time_search_b(items, ITEM_LEN, ITEM_LEN * 4 / 5);
    time_search_b(items, ITEM_LEN, ITEM_LEN);
    clock_gettime(CLOCK_ID, &end);
    t_b = ((end.tv_sec - start.tv_sec) * 1000000000
           + end.tv_nsec - start.tv_nsec);

    clock_gettime(CLOCK_ID, &start);
    time_search_i(items, ITEM_LEN, ITEM_LEN / 5);
    time_search_i(items, ITEM_LEN, ITEM_LEN * 2 / 5);
    time_search_i(items, ITEM_LEN, ITEM_LEN * 3 / 5);
    time_search_i(items, ITEM_LEN, ITEM_LEN * 4 / 5);
    time_search_i(items, ITEM_LEN, ITEM_LEN);
    clock_gettime(CLOCK_ID, &end);
    t_i = ((end.tv_sec - start.tv_sec) * 1000000000
           + end.tv_nsec - start.tv_nsec);
    printf("%s, search_b:\n\t %lld\n", __func__, t_b);
    printf("%s, search_i:\n\t %lld\n", __func__, t_i);

    free(items);
    return 0;
}

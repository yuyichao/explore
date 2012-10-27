#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "lib.h"

char*
strs[] = {
    "jjjjjjjjjjjjjjjjjjjjjjjfadsfapjsidfads",
    "jjjjjjjjjjjjjsidfads",
    "jjjjjjjjjjjjjkkkkkkkkkkkkkkkkkkjjjjjjjjjjfadsfapjsidfads",
    "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmjjjjjjjjjjjjjjjjjjjjjjfadsfapjsidfads",
    "kas;jdjjjjjjjjjjjjjllllllllllllllllllllllllllllllllllljjjjjjjjjjjjjjjjjjjjkajslkdf;ajjjjjjjjjjjfadsfapjsidfads",
    "jkajs;dfajjjjjjjjjjjjnfaksdjjjjjjjjjjjfadsfapjsidfads",
    "jjjjjjasdklpjjjjjjjjjjfbasdfjjjjjjfadsfapjsidfads",
    "jjjjjjdjfalkdsjjjjjjjjdjafpdspjjjjfjjjjjfadsfapjsidfads",
    "jjjjjjaksdlfjpjjjjjjjjjjjjjjnkjdjjjfadsfapjsidfads",
    "jjaksdjjjjjjjjjjjjjjjjjjjjjjfdabsfapjsidfads",
};

size_t str_lens[sizeof(strs) / sizeof(char*)] = {0};
#define N 100000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

int
main()
{
    int strnum = sizeof(strs) / sizeof(char*);
    int i, j;
    void *p = NULL;
    struct timespec start, end;
    long long t;
    for (i = 0;i < strnum;i++) {
        str_lens[i] = strlen(strs[i]);
    }
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < strnum;j++) {
            p = my_strdup(strs[j]);
            free(p);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, strdup:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < strnum;j++) {
            p = my_strndup0(strs[j], str_lens[j]);
            free(p);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, strndup:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < strnum;j++) {
            p = my_strndup1(strs[j], str_lens[j]);
            free(p);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, malloc+memcpy:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < strnum;j++) {
            p = my_setstr(NULL, strs[j], str_lens[j]);
            free(p);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, realloc+memcpy:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < strnum;j++) {
            p = my_setstr2(NULL, strs[j], str_lens[j]);
            free(p);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, if+malloc+memcpy:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < strnum;j++) {
            p = my_strndup2(strs[j], str_lens[j]);
            free(p);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, inline-realloc+memcpy:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < strnum;j++) {
            nop(NULL, strs[j], str_lens[j]);
            nop(NULL, strs[j], str_lens[j]);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, nop*2:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        for (j = 0;j < strnum;j++) {
            nop(NULL, strs[j], str_lens[j]);
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, nop:\n\t %lld\n", __func__, t);
    return 0;
}

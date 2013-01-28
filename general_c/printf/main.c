#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include "lib.h"

#define N 100000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

#define STR1 "aaaaaaaaaaaaaaaaaaaaaaaaaaaa"
#define STR2 "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"
#define STR3 STR1 STR2 STR1 STR2
#define STR4 STR1 STR2 STR1 STR1 STR2 STR3

#define FILE_NAME "test_file"

int
main()
{
    FILE *fp;
    unsigned int i;
    struct timespec start, end;
    long long t;

    fp = fopen(FILE_NAME, "w");
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        print_strs1(fp, STR1, STR2);
    }
    fflush(fp);
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, print_str1.1:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        print_strs1(fp, STR3, STR4);
    }
    fclose(fp);
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, print_str1.2:\n\t %lld\n", __func__, t);

    fp = fopen(FILE_NAME, "w");
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        print_strs3(fp, STR1, STR2);
    }
    fflush(fp);
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, print_str3.1:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        print_strs3(fp, STR3, STR4);
    }
    fclose(fp);
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, print_str3.2:\n\t %lld\n", __func__, t);

    fp = fopen(FILE_NAME, "w");
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        print_strs2(fp, STR1, STR2);
    }
    fflush(fp);
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, print_str2.1:\n\t %lld\n", __func__, t);
    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        print_strs2(fp, STR3, STR4);
    }
    fclose(fp);
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, print_str2.2:\n\t %lld\n", __func__, t);

    return 0;
}

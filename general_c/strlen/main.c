#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>

#define N 100000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC
void *p = NULL;

const char *str = NULL;

#define STR1 "aldasdklfa;"
#define STR2 "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1

#define STR3 "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2 \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2          \
    "ajlka;sdka;lsak;jfalskdj;ldasdklfa;" STR1 STR2 STR2

int
main()
{
    unsigned int i;
    struct timespec start, end;
    long long t;

    clock_gettime(CLOCK_ID, &start);
    str = "";
    for (i = 0;i < N;i++) {
        if (strlen(str) == 0) {
            p = "";
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, empty:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    str = STR1;
    for (i = 0;i < N;i++) {
        if (strlen(str) == 0) {
            p = "";
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, str1:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    str = STR2;
    for (i = 0;i < N;i++) {
        if (strlen(str) == 0) {
            p = "";
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, str2:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    str = STR3;
    for (i = 0;i < N;i++) {
        if (strlen(str) == 0) {
            p = "";
        }
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, str3:\n\t %lld\n", __func__, t);
    return 0;
}

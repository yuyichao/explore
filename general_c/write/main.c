#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>

#define N 1
#define M 100

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

#define WRITE_DATA "a;lsdkfjalskdf;alkdsjf;alks"

int
main(int argc, char **argv)
{
    unsigned int i;
    struct timespec start, end;
    long long t;

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        int fd = open(argv[1], O_CREAT | O_RDWR | O_TRUNC, 0644);
        if (fd < 0) {
            perror("open");
            return -1;
        }
        unsigned int j;
        for (j = 0;j < M;j++) {
            write(fd, WRITE_DATA, sizeof(WRITE_DATA));
        }
        close(fd);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, direct:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        int fd = open(argv[1], O_CREAT | O_RDWR | O_TRUNC);
        if (fd < 0) {
            perror("open");
            return -1;
        }
        FILE *fp = fdopen(fd, "rw");
        unsigned int j;
        for (j = 0;j < M;j++) {
            fwrite(WRITE_DATA, sizeof(WRITE_DATA), 1, fp);
        }
        fclose(fp);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, cache:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        int fd = open(argv[1], O_CREAT | O_RDWR | O_TRUNC, 0644);
        if (fd < 0) {
            perror("open");
            return -1;
        }
        unsigned int j;
        for (j = 0;j < M;j++) {
            write(fd, WRITE_DATA, sizeof(WRITE_DATA));
        }
        close(fd);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, direct:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        int fd = open(argv[1], O_CREAT | O_RDWR | O_TRUNC);
        if (fd < 0) {
            perror("open");
            return -1;
        }
        FILE *fp = fdopen(fd, "rw");
        unsigned int j;
        for (j = 0;j < M;j++) {
            fwrite(WRITE_DATA, sizeof(WRITE_DATA), 1, fp);
        }
        fclose(fp);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, cache:\n\t %lld\n", __func__, t);
    return 0;
}

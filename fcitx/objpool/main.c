#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <fcitx-utils/objpool.h>
#include <fcitx-utils/utils.h>

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

void *p[20000];
#define BUFF_SIZE (sizeof(p) / sizeof(*p))
size_t sizes[] = {1, 10, 100, 200, 500, 20000, 500, 200, 100, 10, 1};
#define SIZES_SIZE (sizeof(sizes) / sizeof(*sizes))

#define OBJ_SIZE 200
#define N 10000
FcitxObjPool *pool;

static void
test_malloc(size_t size)
{
    if (fcitx_unlikely(size > BUFF_SIZE))
        size = BUFF_SIZE;
    size_t i;
    for (i = 0;i < size;i++) {
        p[i] = malloc(OBJ_SIZE);
    }
    for (i = 0;i < size;i++) {
        free(p[i]);
    }
}

static void
test_pool(size_t size)
{
    if (fcitx_unlikely(size > BUFF_SIZE))
        size = BUFF_SIZE;
    size_t i;
    for (i = 0;i < size;i++) {
        p[i] = (void*)(intptr_t)fcitx_obj_pool_alloc_id(pool);
    }
    for (i = 0;i < size;i++) {
        fcitx_obj_pool_free_id(pool, (intptr_t)p[i]);
    }
}

static void
test_sizes(void (*func)(size_t))
{
    unsigned int i;
    for (i = 0;i < SIZES_SIZE;i++) {
        func(sizes[i]);
    }
}

int
main()
{
    unsigned int i;
    struct timespec start, end;
    long long t;

    pool = fcitx_obj_pool_new(OBJ_SIZE);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        test_sizes(test_malloc);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, malloc:\n\t %lld\n", __func__, t);

    clock_gettime(CLOCK_ID, &start);
    for (i = 0;i < N;i++) {
        test_sizes(test_pool);
    }
    clock_gettime(CLOCK_ID, &end);
    t = ((end.tv_sec - start.tv_sec) * 1000000000)
        + end.tv_nsec - start.tv_nsec;
    printf("%s, pool:\n\t %lld\n", __func__, t);

    fcitx_obj_pool_free(pool);
    return 0;
}

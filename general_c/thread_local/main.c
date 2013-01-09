#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <pthread.h>

static __thread int thread_i = 0;

void*
f(void *p)
{
    (void)p;
    thread_i++;
    printf("%s, %p, %i\n", __func__, &thread_i, thread_i);
    return NULL;
}

int
main()
{
    pthread_t thread1;
    pthread_t thread2;
    printf("%s, %p, %i\n", __func__, &thread_i, thread_i);
    pthread_create(&thread1, NULL, f, NULL);
    void *p;
    pthread_join(thread1, &p);
    printf("%s, %p, %i\n", __func__, &thread_i, thread_i);
    pthread_create(&thread2, NULL, f, NULL);
    pthread_join(thread2, &p);
    printf("%s, %p, %i\n", __func__, &thread_i, thread_i);
    return 0;
}

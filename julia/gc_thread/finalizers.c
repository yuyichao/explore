//

#include <stdio.h>

static int b = 0;

void finalizer_for_obj(long *a)
{
    __atomic_fetch_add(a, 1, __ATOMIC_SEQ_CST);
    __atomic_fetch_add(&b, 1, __ATOMIC_SEQ_CST);
}

__attribute__((destructor)) void f(void)
{
    printf("b: %d\n", b);
}

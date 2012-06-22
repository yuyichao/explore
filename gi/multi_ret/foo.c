#include <stdio.h>
#include "foo.h"

/**
 * foo_hello:
 *
 * test
 */
void
foo_hello()
{
    printf("%s\n", __func__);
}

/**
 * foo_make_n_object:
 * @n: n
 * @r: (out): n
 * @objs: (out) (array length=r): array
 *
 * test
 */
void
foo_make_n_object(int n, int *r, GObject ***objs)
{
    int i;
    printf("aaa\n");
    g_return_if_fail(n > 0 && r && objs);

    *r = n;
    *objs = g_new0(GObject*, n);
    for (i = 0;i < n;i++) {
        (*objs)[i] = g_object_new(G_TYPE_OBJECT, NULL);
    }
    printf("bbb\n");
}

/**
 * foo_return_two:
 * @n: (out):
 * @str: (out) (transfer full):
 **/
void foo_return_two(int *n, char **str)
{
    if (n)
        *n = 10;
    if (str)
        *str = g_strdup("asdfasdf");
}

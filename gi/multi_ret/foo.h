#ifndef __FOO_H__
#define __FOO_H__
#include <glib-object.h>

void foo_hello();

void foo_make_n_object(int n, int *r, GObject ***objs);

void foo_return_two(int *n, char **str);

#endif /* __FOO_H__ */

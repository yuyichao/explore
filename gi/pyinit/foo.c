#include "foo.h"

/**
 * foo_n:
 * @type:
 *
 * Return Value: (transfer full):
 **/
GObject*
foo_n(GType type)
{
    return g_object_new(type, NULL);
}

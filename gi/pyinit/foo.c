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

/**
 * foo_n1:
 * @type:
 * @name: (transfer none) (allow-none):
 * @property:
 *
 * Return Value: (transfer full):
 **/
GObject*
foo_n1(GType type, const gchar *name, guint property)
{
    return g_object_new(type, name, property, NULL);
}

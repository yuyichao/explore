#include "mobject.h"
#include "stdio.h"

static void testvm_object_init(TestvmObject *ctx,
                                   TestvmObjectClass *klass);

static void testvm_object_class_init(TestvmObjectClass *klass,
                                         gpointer data);
static void testvm_object_dispose(GObject *obj);
static void testvm_object_finalize(GObject *obj);

GType
testvm_object_get_type()
{
    static GType object_type = 0;
    if (G_UNLIKELY(object_type == 0)) {
      const GTypeInfo object_info = {
          .class_size = sizeof(TestvmObjectClass),
          .base_init = NULL,
          .base_finalize = NULL,
          .class_init = (GClassInitFunc)testvm_object_class_init,
          .class_finalize = NULL,
          .class_data = NULL,
          .instance_size = sizeof(TestvmObject),
          .n_preallocs = 0,
          .instance_init = (GInstanceInitFunc)testvm_object_init,
          .value_table = NULL,
      };

      object_type = g_type_register_static(G_TYPE_OBJECT,
                                           "TestvmObject",
                                           &object_info, 0);
    }
    return object_type;
}

static void
testvm_object_init(TestvmObject *tobj, TestvmObjectClass *klass)
{
}

static void
testvm_object_class_init(TestvmObjectClass *klass, gpointer data)
{
    GObjectClass *gobject_class = G_OBJECT_CLASS(klass);
    /* gobject_class->set_property = testvm_object_set_property; */
    /* gobject_class->get_property = testvm_object_get_property; */
    gobject_class->dispose = testvm_object_dispose;
    gobject_class->finalize = testvm_object_finalize;
    klass->ret_ary = NULL;
    klass->ret_two = NULL;
}

static void
testvm_object_dispose(GObject *obj)
{
}

static void
testvm_object_finalize(GObject *obj)
{
}

/**
 * testvm_object_new:
 *
 * Creates a new wrapper of a javascript object.
 *
 * Return value: the new #TestvmObject
 **/
TestvmObject*
testvm_object_new()
{
    TestvmObject *tobj;
    tobj = g_object_new(TESTVM_TYPE_OBJECT, NULL);
    return tobj;
}

/**
 * TestvmObjectClass::ret_ary:
 * @self: (transfer none) (allow-none):
 * @n: (out) (allow-none):
 *
 * Returns: (transfer full) (array length=n) (element-type int):
 **/

/**
 * TestvmObjectClass::ret_two:
 * @self: (transfer none) (allow-none):
 * @i: (out) (allow-none):
 * @j: (out) (allow-none):
 **/

/**
 * TestvmObjectClass::arg_buff:
 * @self: (transfer none) (allow-none):
 * @n:
 * @buff: (allow-none) (transfer none) (element-type guint8) (array length=n):
 **/

void
print_str(gchar *str)
{
    if (!str)
        printf("(null)\n");
    else
        printf("%s\n", str);
}

/**
 * testvm_object_print:
 * @mobj: mobj
 *
 * Creates a new wrapper of a javascript object.
 **/
void
testvm_object_print(TestvmObject *mobj)
{
    printf("%s\n", __func__);
    TestvmObjectClass *klass = TESTVM_OBJECT_GET_CLASS(mobj);
    if (klass->ret_ary) {
        int *ary;
        int i;
        int n = 0;
        ary = klass->ret_ary(mobj, &n);
        printf("ary: %lx\n", (unsigned long)ary);
        printf("n: %d\n", n);
        for (i = 0;i < n;i++) {
            printf("ary[%d] = %d\n", i, ary[i]);
        }
        g_free(ary);
    } else {
        printf("ret_ary is NULL\n");
    }
    if (klass->ret_two) {
        int i = 0, j = 0;
        klass->ret_two(mobj, &i, &j);
        printf("i: %d, j: %d\n", i, j);
    } else {
        printf("ret_two is NULL\n");
    }
    if (klass->arg_buff) {
        klass->arg_buff(mobj, 10, "0123456789");
    }
}

/**
 * testvm_print_array:
 * @n:
 * @ary: (transfer none) (array length=n) (element-type utf8) (allow-none):
 **/
void
testvm_print_array(int n, gchar **ary)
{
    int i;
    for (i = 0;i < n;i++) {
        print_str(ary[i]);
    }
}

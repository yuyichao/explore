#include "mobject.h"
#include "stdio.h"

static void testvm_object_init(TestvmObject *ctx,
                                   TestvmObjectClass *klass);

static void testvm_object_class_init(TestvmObjectClass *klass,
                                         gpointer data);
static void testvm_object_dispose(GObject *obj);
static void testvm_object_finalize(GObject *obj);

#define DEFINE_DEFAULT(name)                    \
    static void name(TestvmObject *mobj)        \
    {                                           \
        printf("%s\n", __func__);               \
    }

DEFINE_DEFAULT(d_print1)
DEFINE_DEFAULT(d_print2)
DEFINE_DEFAULT(d_wrapper1)
DEFINE_DEFAULT(d_wrapper2)


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
    klass->do_print1 = d_print1;
    klass->do_print2 = d_print2;
    klass->wrapper1 = d_wrapper1;
    klass->wrapper2 = d_wrapper2;
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
 * testvm_object_print1:
 * @mobj: mobj
 *
 * Creates a new wrapper of a javascript object.
 **/
void
testvm_object_print1(TestvmObject *mobj)
{
    printf("%s\n", __func__);
    TESTVM_OBJECT_GET_CLASS(mobj)->do_print1(mobj);
}

/**
 * testvm_object_wrapper1:
 * @mobj: mobj
 *
 * Creates a new wrapper of a javascript object.
 **/
void testvm_object_wrapper1(TestvmObject *mobj)
{
    printf("%s\n", __func__);
    TESTVM_OBJECT_GET_CLASS(mobj)->wrapper1(mobj);
}

/**
 * testvm_object_print2:
 * @mobj: mobj
 *
 * Creates a new wrapper of a javascript object.
 **/
void testvm_object_real_print2(TestvmObject *mobj)
{
    printf("%s\n", __func__);
    TESTVM_OBJECT_GET_CLASS(mobj)->do_print2(mobj);
}

/**
 * testvm_object_wrapper2:
 * @mobj: mobj
 *
 * Creates a new wrapper of a javascript object.
 **/
void testvm_object_real_wrapper2(TestvmObject *mobj)
{
    printf("%s\n", __func__);
    TESTVM_OBJECT_GET_CLASS(mobj)->wrapper2(mobj);
}

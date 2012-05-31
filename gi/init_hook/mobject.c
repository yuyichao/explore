#include "mobject.h"
#include "stdio.h"

//G_DEFINE_TYPE(TestvmObject, testvm_object, G_TYPE_OBJECT);

static void
testvm_object_set_property (GObject *object, guint property_id,
                        const GValue *value, GParamSpec *pspec)
{
    printf("%s\n", __func__);
}
static void
testvm_object_get_property (GObject *object, guint property_id,
                        GValue *value, GParamSpec *pspec)
{
    printf("%s\n", __func__);
}

static void
testvm_object_init(TestvmObject *self, TestvmObjectClass *klass)
{
    if (!klass->self) {
        printf("%lx\n", (glong)klass);
        klass->self = klass;
    }
}

static void
testvm_object_base_init(TestvmObjectClass *klass)
{
    klass->self = NULL;
}


testvm_object_class_init(TestvmObjectClass *klass)
{
    GObjectClass *base_class = G_OBJECT_CLASS (klass);
    base_class->set_property = testvm_object_set_property;
    base_class->get_property = testvm_object_get_property;
}

GType
testvm_object_get_type()
{
    static GType object_type = 0;
    if (G_UNLIKELY(object_type == 0)) {
      const GTypeInfo object_info = {
          .class_size = sizeof(TestvmObjectClass),
          .base_init = (GBaseInitFunc)testvm_object_base_init,
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

/**
 * testvm_object_new:
 *
 * Creates
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
 * aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
 **/
void
testvm_object_print(TestvmObject *mobj)
{
    printf("%s\n", __func__);
}

#include "mderive.h"
#include "stdio.h"

static void
testvm_derive_set_property (GObject *object, guint property_id,
                        const GValue *value, GParamSpec *pspec)
{
    printf("%s\n", __func__);
}

static void
testvm_derive_get_property (GObject *object, guint property_id,
                        GValue *value, GParamSpec *pspec)
{
    printf("%s\n", __func__);
}

static void
testvm_derive_init(TestvmDerive *self, TestvmDeriveClass *klass)
{
}

static void
testvm_derive_base_init(TestvmDeriveClass *klass)
{
}

static void
testvm_derive_class_init(TestvmDeriveClass *klass)
{
    GObjectClass *base_class = G_OBJECT_CLASS (klass);
    base_class->set_property = testvm_derive_set_property;
    base_class->get_property = testvm_derive_get_property;
}

GType
testvm_derive_get_type()
{
    static GType derive_type = 0;
    if (G_UNLIKELY(derive_type == 0)) {
      const GTypeInfo derive_info = {
          .class_size = sizeof(TestvmDeriveClass),
          .base_init = (GBaseInitFunc)testvm_derive_base_init,
          .base_finalize = NULL,
          .class_init = (GClassInitFunc)testvm_derive_class_init,
          .class_finalize = NULL,
          .class_data = NULL,
          .instance_size = sizeof(TestvmDerive),
          .n_preallocs = 0,
          .instance_init = (GInstanceInitFunc)testvm_derive_init,
          .value_table = NULL,
      };

      derive_type = g_type_register_static(TESTVM_TYPE_OBJECT,
                                           "TestvmDerive",
                                           &derive_info, 0);
    }
    return derive_type;
}

/**
 * testvm_derive_new:
 *
 * Creates
 *
 * Return value: the new #TestvmDerive
 **/
TestvmDerive*
testvm_derive_new()
{
    TestvmDerive *tobj;
    tobj = g_object_new(TESTVM_TYPE_DERIVE, NULL);
    return tobj;
}

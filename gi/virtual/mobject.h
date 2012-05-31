#ifndef __TESTVM_OBJECT_H__
#define __TESTVM_OBJECT_H__
#include <glib-object.h>

#define TESTVM_TYPE_OBJECT (testvm_object_get_type())
#define TESTVM_OBJECT(obj)                                          \
    (G_TYPE_CHECK_INSTANCE_CAST((obj), TESTVM_TYPE_OBJECT, TestvmObject))
#define TESTVM_IS_OBJECT(obj)                                       \
    (G_TYPE_CHECK_INSTANCE_TYPE((obj), TESTVM_TYPE_OBJECT))
#define TESTVM_OBJECT_CLASS(klass)                                  \
    (G_TYPE_CHECK_CLASS_CAST((klass), TESTVM_TYPE_OBJECT,           \
                             TestvmObjectClass))
#define TESTVM_IS_OBJECT_CLASS(klass)                       \
    (G_TYPE_CHECK_CLASS_TYPE((klass), TESTVM_TYPE_OBJECT))
#define TESTVM_OBJECT_GET_CLASS(obj)                                \
    (G_TYPE_INSTANCE_GET_CLASS((obj), TESTVM_TYPE_OBJECT,           \
                               TestvmObjectClass))

typedef struct _TestvmObject TestvmObject;
typedef struct _TestvmObjectClass TestvmObjectClass;

struct _TestvmObject {
    GObject parent;
};

struct _TestvmObjectClass {
    GObjectClass parent_class;
    void (*do_print1)(TestvmObject *mobj);
    void (*do_print2)(TestvmObject *mobj);
    void (*wrapper1)(TestvmObject *mobj);
    void (*wrapper2)(TestvmObject *mobj);
};

#ifdef __cplusplus
extern "C" {
#endif
    GType testvm_object_get_type();
    TestvmObject *testvm_object_new();
    void testvm_object_print1(TestvmObject *mobj);
    void testvm_object_wrapper1(TestvmObject *mobj);
    void testvm_object_real_print2(TestvmObject *mobj);
    void testvm_object_real_wrapper2(TestvmObject *mobj);
#ifdef __cplusplus
}
#endif

#endif /* __TESTVM_OBJECT_H__ */

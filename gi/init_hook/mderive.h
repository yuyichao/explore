#ifndef __TESTVM_DERIVE_H__
#define __TESTVM_DERIVE_H__
#include <mobject.h>

#define TESTVM_TYPE_DERIVE (testvm_derive_get_type())
#define TESTVM_DERIVE(obj)                                          \
    (G_TYPE_CHECK_INSTANCE_CAST((obj), TESTVM_TYPE_DERIVE, TestvmDerive))
#define TESTVM_IS_DERIVE(obj)                                       \
    (G_TYPE_CHECK_INSTANCE_TYPE((obj), TESTVM_TYPE_DERIVE))
#define TESTVM_DERIVE_CLASS(klass)                                  \
    (G_TYPE_CHECK_CLASS_CAST((klass), TESTVM_TYPE_DERIVE,           \
                             TestvmDeriveClass))
#define TESTVM_IS_DERIVE_CLASS(klass)                       \
    (G_TYPE_CHECK_CLASS_TYPE((klass), TESTVM_TYPE_DERIVE))
#define TESTVM_DERIVE_GET_CLASS(obj)                                \
    (G_TYPE_INSTANCE_GET_CLASS((obj), TESTVM_TYPE_DERIVE,           \
                               TestvmDeriveClass))

typedef struct _TestvmDerive TestvmDerive;
typedef struct _TestvmDeriveClass TestvmDeriveClass;

struct _TestvmDerive {
    TestvmObject parent;
};

struct _TestvmDeriveClass {
    TestvmObjectClass parent_class;
};

#ifdef __cplusplus
extern "C" {
#endif
    GType testvm_derive_get_type();
    TestvmDerive *testvm_derive_new();
#ifdef __cplusplus
}
#endif

#endif /* __TESTVM_DERIVE_H__ */

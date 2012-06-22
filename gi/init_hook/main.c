#include "mderive.h"
#include "mobject.h"
#include <stdio.h>

int
main()
{
    g_type_init();
    TestvmObject *obj1 = testvm_object_new();
    printf("1\n");
    TestvmObject *obj2 = testvm_object_new();
    printf("2\n");
    TestvmDerive *der1 = testvm_derive_new();
    printf("3\n");
    TestvmDerive *der2 = testvm_derive_new();
    printf("4\n");
    printf("%lx\n", TESTVM_OBJECT_GET_CLASS(obj1)->self);
    printf("%lx\n", TESTVM_OBJECT_GET_CLASS(obj2)->self);
    printf("%lx\n", TESTVM_OBJECT_GET_CLASS(der1)->self);
    printf("%lx\n", TESTVM_OBJECT_GET_CLASS(der2)->self);
    return 0;
}

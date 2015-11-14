#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

typedef struct _jl_value_t jl_value_t;

typedef struct {
    union {
        jl_value_t *type; // 16-bytes aligned
        uintptr_t type_bits;
        struct {
            uintptr_t gc_bits:2;
        };
    };
    void *value[];
} jl_taggedvalue_t;

int
main()
{
    jl_taggedvalue_t a;
    jl_taggedvalue_t *pa = &a;
    /* char *pc = (char*)pa; */
    printf("%s, %d\n", __func__, (int)offsetof(jl_taggedvalue_t, value));
    /* printf("%s, %p\n", __func__, (jl_taggedvalue_t*)pc->type); */
    printf("%s, %p\n", __func__, (char*)pa->type);
}

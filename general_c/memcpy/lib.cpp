#include "lib.h"

#define __FCITX_BYTE_CAST(new_val, old_type, old_val) do {      \
        old_type __fx_byte_cast_old = (old_val);                \
        memset(&new_val, 0, sizeof(new_val));                   \
        memcpy(&new_val, &__fx_byte_cast_old,                   \
               sizeof(old_type) < sizeof(new_val) ?             \
               sizeof(old_type) : sizeof(new_val));             \
    } while (0)

#define _FCITX_CAST_TO_INT(new_type, new_val, old_type, old_val) do {   \
        if (sizeof(old_type) <= 1) {                                    \
            uint8_t __fx_cast_to_int_tmp;                               \
            __FCITX_BYTE_CAST(__fx_cast_to_int_tmp, old_type, old_val); \
            new_val = (new_type)__fx_cast_to_int_tmp;                   \
        } else if (sizeof(old_type) <= 2) {                             \
            uint16_t __fx_cast_to_int_tmp;                              \
            __FCITX_BYTE_CAST(__fx_cast_to_int_tmp, old_type, old_val); \
            new_val = (new_type)__fx_cast_to_int_tmp;                   \
        } else if (sizeof(old_type) <= 4) {                             \
            uint32_t __fx_cast_to_int_tmp;                              \
            __FCITX_BYTE_CAST(__fx_cast_to_int_tmp, old_type, old_val); \
            new_val = (new_type)__fx_cast_to_int_tmp;                   \
        } else {                                                        \
            uint64_t __fx_cast_to_int_tmp;                              \
            __FCITX_BYTE_CAST(__fx_cast_to_int_tmp, old_type, old_val); \
            new_val = (new_type)__fx_cast_to_int_tmp;                   \
        }                                                               \
    } while (0)

#define FCITX_DEF_CAST_TO_INT(new_type, new_val, old_type, old_val)     \
    new_type new_val;                                                   \
    _FCITX_CAST_TO_INT(new_type, new_val, old_type, old_val)

#define FCITX_RETURN_AS_INT(new_type, old_type, old_val) do {   \
        FCITX_DEF_CAST_TO_INT(new_type, __fx_return_as_int_tmp, \
                              old_type, old_val);               \
        return __fx_return_as_int_tmp;                          \
    } while (0)

int
float_to_int1(float f)
{
    FCITX_RETURN_AS_INT(int, float, f);
}

int
float_to_int2(float f)
{
    void *p = &f;
    return *((int*)p);
}

int
float_to_int3(float f)
{
    int i = 0;
    memcpy(&i, &f, sizeof(f));
    return i;
}

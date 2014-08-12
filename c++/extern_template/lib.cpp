#define __LIB_CPP_PRIVATE__

#include "lib.h"

template<>
int
extern_template<0>()
{
    return extern_template<1>();
}

template int extern_template<0>();

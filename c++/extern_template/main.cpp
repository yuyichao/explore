#include "lib.h"

#include <assert.h>

#include <iostream>

int
main()
{
    std::cout << "extern_template<0>(): " << extern_template<0>() << std::endl;
    std::cout << "extern_template<1>(): " << extern_template<1>() << std::endl;
    std::cout << "extern_template<2>(): " << extern_template<2>() << std::endl;
    assert(extern_template<0>() == 1);
    assert(extern_template<1>() == 1);
    assert(extern_template<2>() == 2);
    return 0;
}

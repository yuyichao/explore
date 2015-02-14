#include <assert.h>

#include <iostream>
#include <initializer_list>
#include <utility>
#include <array>
#include <valarray>

template<typename E>
static inline auto
testFunc(E&& v...)
{
    return v;
}


int
main()
{
    std::cout << testFunc<int>(1, 2) << std::endl;
    return 0;
}

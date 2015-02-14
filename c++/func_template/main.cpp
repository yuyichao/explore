#include <assert.h>

#include <iostream>
#include <utility>

template<typename Type>
static Type
testFunc()
{
    return Type();
}

template<typename Func>
static auto
testFunc2(Func &&f) -> decltype(std::forward<Func>(f)())
{
    return std::forward<Func>(f)();
}

int
main()
{
    testFunc2(testFunc<int>);
    return 0;
}

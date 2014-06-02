#include <tuple>
#include <utility>
#include <iostream>

#include "print_arg.h"
#include "call_tuple.h"

template<typename... Args>
static inline void
print_tuple(std::tuple<Args...> &&args)
{
    call_tuple([] (Args&&... args) {
            print_arg(std::forward<Args>(args)...);
        }, std::move(args));
}

void
print1(int a, int b, int c)
{
    print_arg(a, b, c);
}

void
print2(int a, int b, int c)
{
    print_tuple(std::make_tuple(a, b, c));
}

template<typename... Args>
static inline void
print_convert(Args&&... args)
{
    std::tuple<Args&&...> arg_pack(std::forward<Args>(args)...);
}

int
main()
{
    print1(1, 2, 3);
    print2(1, 2, 3);
}

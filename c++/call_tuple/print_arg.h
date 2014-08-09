#include "utils.h"

#include <iostream>

#ifndef __PRINT_ARG_H__
#define __PRINT_ARG_H__

static inline void
_print_arg()
{
}

template<typename T, typename... Args>
static inline void
_print_arg(T &&arg, Args&&... args)
{
    std::cout << std::forward<T>(arg);
    _print_arg(std::forward<Args>(args)...);
}

template<typename... Args>
static inline void
print_arg(Args&&... args)
{
    _print_arg(std::forward<Args>(args)...);
    std::cout << std::endl;
}

#endif

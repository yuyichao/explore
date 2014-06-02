#include "utils.h"
#include <tuple>

#ifndef __CONVERT_ARGS_H__
#define __CONVERT_ARGS_H__

template<typename T, class = void>
class Arg {
    T &m_arg;
public:
    Arg(T &arg)
        : m_arg(arg)
    {}
    inline T&
    get()
    {
        return m_arg;
    }
};

template<typename T>
static inline std::tuple<T&>
ensure_tuple(T &obj)
{
    return std:tie(obj);
}

template<typename... Args>
static inline std::tuple<Args...&>&
ensure_tuple(std::tuple<Args...&> &arg)
{
    return arg;
}

template<typename... Res>
static inline std::tuple<>
_get_arg()
{
}

template<typename T, class = void>
class PrintArg {
    PrintArg()
    {
    }
};

#endif

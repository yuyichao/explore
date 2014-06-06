#include <utility>
#include <functional>

#ifndef __CALL_TUPLE_H__
#define __CALL_TUPLE_H__

template<int...>
struct seq {
};

template<int N, int... S>
struct gens : gens<N - 1, N - 1, S...> {
};

template<int ...S>
struct gens<0, S...> {
    typedef seq<S...> type;
};

template<typename Function, int... S, typename... Arg2>
static inline auto
_call_func(Function func, seq<S...>, std::tuple<Arg2...> &args)
    -> decltype(func(std::forward<Arg2>(std::get<S>(args))...))
{
    return func(static_cast<Arg2&&>(std::get<S>(args))...);
}

template<typename Function, typename T>
static inline auto
call_tuple(Function &&func, T args)
    -> decltype(_call_func(std::forward<Function>(func),
                           typename gens<std::tuple_size<T>::value>::type(),
                           args))
{
    return _call_func(std::forward<Function>(func),
                      typename gens<std::tuple_size<T>::value>::type(), args);
}

#endif

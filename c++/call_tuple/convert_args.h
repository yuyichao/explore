#include "utils.h"
#include "call_tuple.h"
#include "typename.h"

#include <tuple>
#include <iostream>

#ifndef __CONVERT_ARGS_H__
#define __CONVERT_ARGS_H__

template<typename T, typename... Ts>
struct _print_type {
    static inline void
    print()
    {
        std::cout << type_name<T>() << ", ";
        _print_type<Ts...>::print();
    }
};

template<typename T>
struct _print_type<T> {
    static inline void
    print()
    {
        std::cout << type_name<T>();
    }
};

template<typename... Ts>
static inline void
print_type()
{
    _print_type<Ts...>::print();
    std::cout << std::endl;
}

template<typename T>
using _ArgType = typename std::remove_const<
    typename std::remove_reference<T>::type>::type;

template<template<typename...> class Convert, typename... Types>
using _ArgPackBase = std::tuple<Convert<_ArgType<Types> >...>;

template<template<typename...> class Convert, typename... Types>
class ArgPack : public _ArgPackBase<Convert, Types...> {
    template<typename T>
    static inline std::tuple<T&&>
    ensure_tuple(T &&arg)
    {
        return std::tuple<T&&>(std::forward<T>(arg));
    }
    template<typename... T>
    static inline std::tuple<T...>&&
    ensure_tuple(std::tuple<T...> &&t)
    {
        return std::move(t);
    }

    template<typename T>
    using ArgConvert = Convert<_ArgType<T> >;
    template<template<typename...> class Getter, typename... Extra, int... S>
    inline auto
    __get(seq<S...>)
    -> decltype(std::tuple_cat(ensure_tuple(Getter<ArgConvert<Types>,
                                            Extra...>::get(
                                                std::get<S>(*this)))...))
    {
        return std::tuple_cat(ensure_tuple(Getter<ArgConvert<Types>,
                                           Extra...>::get(
                                               std::get<S>(*this)))...);
    }
public:
    template<typename... Types2>
    ArgPack(Types2&&... arg)
        : _ArgPackBase<Convert, Types...>(ArgConvert<Types2>(arg)...)
    {
        std::cout << "_print_type<Types...>()" << std::endl;
        print_type<Types...>();

        std::cout << "print_type<Types2&&...>()" << std::endl;
        print_type<Types2&&...>();
        std::cout << "_print_type<Types2...>()" << std::endl;
        print_type<Types2...>();
    }
    ArgPack(ArgPack &&other)
        : _ArgPackBase<Convert, Types...>(std::move(other))
    {
    }
    // GCC Bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=57543
    template<template<typename...> class Getter, typename... Extra>
    inline auto
    get() -> decltype(this->__get<Getter, Extra...>(
                          typename gens<sizeof...(Types)>::type()))
    {
        return __get<Getter, Extra...>(typename gens<sizeof...(Types)>::type());
    }
    template<template<typename...> class Getter,
             typename... Extra, typename Func>
    inline auto
    call(Func func)
        -> decltype(call_tuple(func, this->get<Getter, Extra...>()))
    {
        return call_tuple(func, get<Getter, Extra...>());
    }
};

template<template<typename...> class Convert, typename... Types>
static inline ArgPack<Convert, typename std::remove_reference<Types>::type...>
make_argpack(Types&&... args)
{
    return ArgPack<Convert, typename std::remove_reference<Types>::type...>(
        std::forward<Types>(args)...);
}

#endif

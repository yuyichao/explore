#include <utility>
#include <iostream>

#define ALWAYS_INLINE __attribute__((always_inline))

int
func(int, float)
{
    return 0;
}

template<typename Func, typename... Args>
struct wrapper1 {
    ALWAYS_INLINE static inline auto
    call(Func &&func, Args&&... args)
        -> decltype(func(std::forward<Args>(args)...))
    {
        std::cout << "wrap_func1" << std::endl;
        return func(std::forward<Args>(args)...);
    }
};
template<typename Func, typename... Args>
ALWAYS_INLINE static inline auto
wrap_func1(Func &&func, Args&&... args)
    -> decltype(wrapper1<Func, Args...>::call(std::forward<Func>(func),
                                              std::forward<Args>(args)...))
{
    return wrapper1<Func, Args...>::call(std::forward<Func>(func),
                                         std::forward<Args>(args)...);
}

template<typename Func, typename... Args>
struct wrapper2 {
    ALWAYS_INLINE static inline auto
    call(Func &&func, Args&&... args)
        -> decltype(func(std::forward<Args>(args)...))
    {
        std::cout << "wrap_func2" << std::endl;
        return func(std::forward<Args>(args)...);
    }
};
template<typename Func, typename... Args>
ALWAYS_INLINE static inline auto
wrap_func2(Func &&func, Args&&... args)
    -> decltype(wrapper2<Func, Args...>::call(std::forward<Func>(func),
                                              std::forward<Args>(args)...))
{
    return wrapper2<Func, Args...>::call(std::forward<Func>(func),
                                         std::forward<Args>(args)...);
}

template<template<typename...> class wrapper = wrapper1,
         typename Func, typename... Args>
ALWAYS_INLINE static inline auto
super_wrap(Func &&func, Args&&... args)
    -> decltype(wrapper<Func, Args...>::call(std::forward<Func>(func),
                                             std::forward<Args>(args)...))
{
    return wrapper<Func, Args...>::call(std::forward<Func>(func),
                                        std::forward<Args>(args)...);
}

int
main()
{
    wrap_func1(func, 1, 2);
    wrap_func2(func, 2, 2);
    super_wrap(func, 1, 2);
    super_wrap<wrapper1>(func, 1, 2);
    super_wrap<wrapper2>(func, 1, 2);

    super_wrap<wrapper2>([] (int*) {}, nullptr);
    return 0;
}

#include <assert.h>

#include <iostream>
#include <utility>
#include <functional>

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

template<typename Func, typename... Args>
static inline auto
caller(Func &&func, Args&&... args)
    -> decltype(func(std::forward<Args>(args)...))
{
    return func(std::forward<Args>(args)...);
}

template<typename Func, typename... Args>
static inline auto
caller(Func &&func, Args&&... args)
    -> decltype(func(0, std::forward<Args>(args)...))
{
    return func(0, std::forward<Args>(args)...);
}

template<typename Func, typename... Args>
static inline auto
wrapper(Func &&func, Args&&... args)
    -> decltype(caller(std::forward<Func>(func),
                       std::forward<Args>(args)...))
{
    return caller<Func, Args...>(
        std::forward<Func>(func), std::forward<Args>(args)...);
}

template<typename Func, typename... Args>
static inline auto
caller2(size_t, Func &func, Args&... args)
    -> decltype(func(args...))
{
    return func(args...);
}

template<typename Func, typename... Args>
static inline auto
caller2(size_t i, Func &func, Args&... args)
    -> decltype(func(i, args...))
{
    return func(i, args...);
}

template<typename Func, typename... Args>
static inline void
binder(Func &&func, Args&&... args)
{
    auto f = std::bind(caller2<typename std::decay<Func>::type,
                       typename std::decay<Args>::type...>,
                       std::placeholders::_1,
                       std::forward<Func>(func),
                       std::forward<Args>(args)...);
    int i = 0;
    f(i);
}

static void
testFunc3(size_t, void*)
{
}

int
main()
{
    testFunc2(testFunc<int>);
    wrapper([] (size_t) {});
    wrapper([] () {});
    // Clang error
    // wrapper([] (size_t, void*) {}, nullptr);
    // wrapper([] (void*) {}, nullptr);

    binder([] () {});
    binder([] (void*) {}, nullptr);
    void *p = nullptr;
    binder([] (void*) {}, p);
    const auto &p2 = nullptr;
    binder([] (void*) {}, p2);
    binder([] (size_t) {});
    binder([] (size_t, void*) {}, nullptr);
    binder([] (size_t, void*) {}, p);
    binder([] (size_t, void*) {}, p2);
    void (*fp)(size_t, void*) = [] (size_t, void*) {};
    binder(fp, nullptr);
    binder(fp, p);
    binder(fp, p2);
    binder(testFunc3, nullptr);
    binder(testFunc3, p);
    binder(testFunc3, p2);
    return 0;
}

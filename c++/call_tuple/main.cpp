#include <tuple>
#include <utility>
#include <iostream>
#include <string>
#include <memory>
#ifndef _MSC_VER
#  include <cxxabi.h>
#endif

#include "print_arg.h"
#include "call_tuple.h"
#include "convert_args.h"

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

void
print3(float a, float b, float c, float d)
{
    print_tuple(std::make_tuple(a, b, c, d));
}

template<typename... Args>
static inline void
print_convert(Args&&... args)
{
    std::tuple<Args&&...> arg_pack(std::forward<Args>(args)...);
}

template<typename T>
class C {
private:
    T m_t;
public:
    C(T t)
        : m_t(t)
    {
    }
};

template<typename T, typename T2>
struct G;

template<>
struct G<C<int>, float> {
    template<typename... Args>
    static inline std::tuple<float, float>
    get(Args...)
    {
        return std::tuple<float, float>(0, 2);
    }
};

template <class T>
std::string
type_name()
{
    typedef typename std::remove_reference<T>::type TR;
    std::unique_ptr<char, void(*)(void*)> own(
#ifndef _MSC_VER
        abi::__cxa_demangle(typeid(TR).name(), nullptr,
                            nullptr, nullptr),
#else
        nullptr,
#endif
        std::free);
    std::string r = own != nullptr ? own.get() : typeid(TR).name();
    if (std::is_const<TR>::value)
        r += " const";
    if (std::is_volatile<TR>::value)
        r += " volatile";
    if (std::is_lvalue_reference<T>::value)
        r += "&";
    else if (std::is_rvalue_reference<T>::value)
        r += "&&";
    return r;
}

int
main()
{
    print1(1, 2, 3);
    print2(1, 2, 3);
    auto pack = make_argpack<C>(1, 2);
    std::cout << type_name<decltype(pack)>() << std::endl;
    auto arg = pack.get<G, float>();
    std::cout << type_name<decltype(arg)>() << std::endl;
    pack.call<G, float>(print3);
    auto f = [] {};
    std::cout << type_name<decltype(f)>() << std::endl;
    auto &_pack = pack;
    std::cout << type_name<decltype(_pack)>() << std::endl;
    std::cout << type_name<decltype(std::move(_pack))>() << std::endl;
}

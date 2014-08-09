#include "convert_args.h"
#include "call_tuple.h"
#include "print_arg.h"
#include "typename.h"

#include <tuple>
#include <utility>

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

    std::cout << type_name<decltype(make_argpack<C>())>() << std::endl;
    std::cout << type_name<decltype(make_argpack<C>(std::declval<int>(),
                                                    std::declval<int&>(),
                                                    std::declval<int&&>()))>()
              << std::endl;

    int i = 0;
    int &ia = i;
    int &&iaa = std::move(i);
    make_argpack<C>(std::move(iaa), ia, i, ([] {return 0;})());
}

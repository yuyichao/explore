//

#include <stdio.h>
#include <stdint.h>
#include <type_traits>

// sum dummy functions that we want to dispatch to.
static inline void f1(void)
{
    printf("1\n");
}
static inline void f2(void)
{
    printf("2\n");
}
static inline void f3(void)
{
    printf("3\n");
}
static inline void f4(void)
{
    printf("4\n");
}

template<typename T, typename T2>
static inline typename std::enable_if<sizeof(T) == 1>::type g(T*, T2)
{
    f1();
}
template<typename T, typename T2>
static inline typename std::enable_if<sizeof(T) == 2>::type g(T*, T2)
{
    f2();
}
template<typename T, typename T2>
static inline typename std::enable_if<sizeof(T) == 4>::type g(T*, T2)
{
    f3();
}
template<typename T, typename T2>
static inline typename std::enable_if<sizeof(T) == 8>::type g(T*, T2)
{
    f4();
}

int main()
{
    int8_t a = 0;
    int16_t b = 0;
    int32_t c = 0;
    int64_t d = 0;
    g(&a, d);
    g(&b, c);
    g(&c, b);
    g(&d, a);
    return 0;
}

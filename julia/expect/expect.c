//

#include <stdint.h>

__attribute__((noinline)) int64_t
f1(int64_t x)
{
    if (x > 0) {
        return x;
    } else {
        return 2;
    }
}

__attribute__((noinline)) int64_t
f2(int64_t x)
{
    if (__builtin_expect(x > 0, 1)) {
        return x;
    } else {
        return 2;
    }
}

__attribute__((noinline)) int64_t
f3(int64_t x)
{
    if (__builtin_expect(x > 0, 0)) {
        return x;
    } else {
        return 2;
    }
}

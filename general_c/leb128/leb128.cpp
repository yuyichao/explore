//

#include <assert.h>
#include <stdint.h>
#include <type_traits>
#include <stdio.h>

template<typename T> static inline T parse_leb128(const uint8_t *&Addr)
{
    typedef typename std::make_unsigned<T>::type uT;
    uT v = 0;
    for (int i = 0;i < ((sizeof(T) * 8 - 1) / 7 + 1);i++) {
        uint8_t a = *Addr;
        Addr++;
        v |= uT(a & 0x7f) << (i * 7);
        if ((a & 0x80) == 0) {
            if (a & 0x40 && std::is_signed<T>::value) {
                int valid_bits = (i + 1) * 7;
                if (valid_bits < 64) {
                    v |= -(uT(1) << valid_bits);
                }
            }
            return T(v);
        }
    }
    assert(0 && "LEB128 encoding too long");
    return T(v);
}

int main()
{
    const uint8_t buff[] = {0x80, 0x80, 0x7f, 0x80, 0x01};
    const uint8_t *p = buff;
    auto s1 = parse_leb128<int>(p);
    auto u1 = parse_leb128<unsigned>(p);
    printf("s1: %x; u1: %x; buff: %p; p: %p\n", s1, u1, buff, p);
    return 0;
}

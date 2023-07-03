//

#include <arm_neon.h>
#include <stdint.h>
#include <bit>

static int multiply_0(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s, int length)
{
    uint64_t hi = 0;
    uint64_t lo = 0;
    for (int i = 0; i < length; i += 1) {
        auto x1 = x1s[i];
        auto x2 = x2s[i];
        x1s[i] = x1 ^ x2;

        auto z1 = z1s[i];
        auto z2 = z2s[i];
        z1s[i] = z1 ^ z2;

        auto v1 = x1 & z2;
        auto v2 = x2 & z1;
        auto m = (z2 ^ x1) | ~(x2 | z1);
        auto change = v1 ^ v2;
        hi = hi ^ ((m ^ lo) & change);
        lo = lo ^ change;
    }
    auto cnt_lo = std::popcount(lo);
    auto cnt_hi = std::popcount(hi) << 1;
    return (cnt_lo + cnt_hi) & 3;
}

static int multiply_1(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s, int length)
{
    auto hi = vdupq_n_u64(0);
    auto lo = vdupq_n_u64(0);
    for (int i = 0; i < length; i += 2) {
        auto x1 = vld1q_u64(&x1s[i]);
        auto x2 = vld1q_u64(&x2s[i]);
        vst1q_u64(&x1s[i], x1 ^ x2);

        auto z1 = vld1q_u64(&z1s[i]);
        auto z2 = vld1q_u64(&z2s[i]);
        vst1q_u64(&z1s[i], z1 ^ z2);

        auto v1 = x1 & z2;
        auto v2 = x2 & z1;
        auto m = (z2 ^ x1) | ~(x2 | z1);
        auto change = v1 ^ v2;
        hi = hi ^ ((m ^ lo) & change);
        lo = lo ^ change;
    }
    auto cnt_lo = vcntq_u8((uint8x16_t)lo);
    auto cnt_hi = vcntq_u8((uint8x16_t)hi);
    cnt_hi = vshlq_n_u8(cnt_hi, 1);
    auto cnt = cnt_lo + cnt_hi;
    return vaddvq_u8(cnt) & 3;
}

static int multiply_1x2_1(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s,
                          int length)
{
    auto hi = vdupq_n_u64(0);
    auto lo = vdupq_n_u64(0);
    for (int i = 0; i < length; i += 4) {
        auto x1_1 = vld1q_u64(&x1s[i]);
        auto x1_2 = vld1q_u64(&x1s[i + 2]);
        auto x2_1 = vld1q_u64(&x2s[i]);
        auto x2_2 = vld1q_u64(&x2s[i + 2]);
        vst1q_u64(&x1s[i], x1_1 | x2_1);
        vst1q_u64(&x1s[i + 2], x1_2 | x2_2);

        auto z1_1 = vld1q_u64(&z1s[i]);
        auto z1_2 = vld1q_u64(&z1s[i + 2]);
        auto z2_1 = vld1q_u64(&z2s[i]);
        auto z2_2 = vld1q_u64(&z2s[i + 2]);
        vst1q_u64(&z1s[i], z1_1 | z2_1);
        vst1q_u64(&z1s[i + 2], z1_2 | z2_2);

        auto v1_1 = x1_1 & z2_1;
        auto v1_2 = x1_2 & z2_2;
        auto v2_1 = x2_1 & z1_1;
        auto v2_2 = x2_2 & z1_2;
        auto m_1 = (z2_1 ^ x1_1) | ~(x2_1 | z1_1);
        auto m_2 = (z2_2 ^ x1_2) | ~(x2_2 | z1_2);
        auto change_1 = v1_1 ^ v2_1;
        auto change_2 = v1_2 ^ v2_2;
        hi = hi ^ ((m_1 ^ lo) & change_1);
        lo = lo ^ change_1;
        hi = hi ^ ((m_2 ^ lo) & change_2);
        lo = lo ^ change_2;
    }
    auto cnt_lo = vcntq_u8((uint8x16_t)lo);
    auto cnt_hi = vcntq_u8((uint8x16_t)hi);
    cnt_hi = vshlq_n_u8(cnt_hi, 1);
    auto cnt = cnt_lo + cnt_hi;
    return vaddvq_u8(cnt) & 3;
}

static int multiply_1x2_2(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s,
                          int length)
{
    auto hi = vdupq_n_u64(0);
    auto lo = vdupq_n_u64(0);
    for (int i = 0; i < length; i += 4) {
        auto x1 = vld2q_u64(&x1s[i]);
        auto x2 = vld2q_u64(&x2s[i]);
        auto x1_1 = x1.val[0];
        auto x1_2 = x1.val[1];
        auto x2_1 = x2.val[0];
        auto x2_2 = x2.val[1];
        vst2q_u64(&x1s[i], (uint64x2x2_t{ x1_1 | x2_1, x1_2 | x2_2 }));

        auto z1 = vld2q_u64(&z1s[i]);
        auto z2 = vld2q_u64(&z2s[i]);
        auto z1_1 = z1.val[0];
        auto z1_2 = z1.val[1];
        auto z2_1 = z2.val[0];
        auto z2_2 = z2.val[1];
        vst2q_u64(&z1s[i], (uint64x2x2_t{ z1_1 | z2_1, z1_2 | z2_2 }));

        auto v1_1 = x1_1 & z2_1;
        auto v1_2 = x1_2 & z2_2;
        auto v2_1 = x2_1 & z1_1;
        auto v2_2 = x2_2 & z1_2;
        auto m_1 = (z2_1 ^ x1_1) | ~(x2_1 | z1_1);
        auto m_2 = (z2_2 ^ x1_2) | ~(x2_2 | z1_2);
        auto change_1 = v1_1 ^ v2_1;
        auto change_2 = v1_2 ^ v2_2;
        hi = hi ^ ((m_1 ^ lo) & change_1);
        lo = lo ^ change_1;
        hi = hi ^ ((m_2 ^ lo) & change_2);
        lo = lo ^ change_2;
    }
    auto cnt_lo = vcntq_u8((uint8x16_t)lo);
    auto cnt_hi = vcntq_u8((uint8x16_t)hi);
    cnt_hi = vshlq_n_u8(cnt_hi, 1);
    auto cnt = cnt_lo + cnt_hi;
    return vaddvq_u8(cnt) & 3;
}

static int multiply_1x4_1(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s,
                          int length)
{
    auto hi = vdupq_n_u64(0);
    auto lo = vdupq_n_u64(0);
    for (int i = 0; i < length; i += 8) {
        auto x1_1 = vld1q_u64(&x1s[i]);
        auto x1_2 = vld1q_u64(&x1s[i + 2]);
        auto x1_3 = vld1q_u64(&x1s[i + 4]);
        auto x1_4 = vld1q_u64(&x1s[i + 6]);
        auto x2_1 = vld1q_u64(&x2s[i]);
        auto x2_2 = vld1q_u64(&x2s[i + 2]);
        auto x2_3 = vld1q_u64(&x2s[i + 4]);
        auto x2_4 = vld1q_u64(&x2s[i + 6]);
        vst1q_u64(&x1s[i], x1_1 | x2_1);
        vst1q_u64(&x1s[i + 2], x1_2 | x2_2);
        vst1q_u64(&x1s[i + 4], x1_3 | x2_3);
        vst1q_u64(&x1s[i + 6], x1_4 | x2_4);

        auto z1_1 = vld1q_u64(&z1s[i]);
        auto z1_2 = vld1q_u64(&z1s[i + 2]);
        auto z1_3 = vld1q_u64(&z1s[i + 4]);
        auto z1_4 = vld1q_u64(&z1s[i + 6]);
        auto z2_1 = vld1q_u64(&z2s[i]);
        auto z2_2 = vld1q_u64(&z2s[i + 2]);
        auto z2_3 = vld1q_u64(&z2s[i + 4]);
        auto z2_4 = vld1q_u64(&z2s[i + 6]);
        vst1q_u64(&z1s[i], z1_1 | z2_1);
        vst1q_u64(&z1s[i + 2], z1_2 | z2_2);
        vst1q_u64(&z1s[i + 4], z1_3 | z2_3);
        vst1q_u64(&z1s[i + 6], z1_4 | z2_4);

        auto v1_1 = x1_1 & z2_1;
        auto v1_2 = x1_2 & z2_2;
        auto v1_3 = x1_3 & z2_3;
        auto v1_4 = x1_4 & z2_4;
        auto v2_1 = x2_1 & z1_1;
        auto v2_2 = x2_2 & z1_2;
        auto v2_3 = x2_3 & z1_3;
        auto v2_4 = x2_4 & z1_4;
        auto m_1 = (z2_1 ^ x1_1) | ~(x2_1 | z1_1);
        auto m_2 = (z2_2 ^ x1_2) | ~(x2_2 | z1_2);
        auto m_3 = (z2_3 ^ x1_3) | ~(x2_3 | z1_3);
        auto m_4 = (z2_4 ^ x1_4) | ~(x2_4 | z1_4);
        auto change_1 = v1_1 ^ v2_1;
        auto change_2 = v1_2 ^ v2_2;
        auto change_3 = v1_3 ^ v2_3;
        auto change_4 = v1_4 ^ v2_4;
        hi = hi ^ ((m_1 ^ lo) & change_1);
        lo = lo ^ change_1;
        hi = hi ^ ((m_2 ^ lo) & change_2);
        lo = lo ^ change_2;
        hi = hi ^ ((m_3 ^ lo) & change_3);
        lo = lo ^ change_3;
        hi = hi ^ ((m_4 ^ lo) & change_4);
        lo = lo ^ change_4;
    }
    auto cnt_lo = vcntq_u8((uint8x16_t)lo);
    auto cnt_hi = vcntq_u8((uint8x16_t)hi);
    cnt_hi = vshlq_n_u8(cnt_hi, 1);
    auto cnt = cnt_lo + cnt_hi;
    return vaddvq_u8(cnt) & 3;
}

static int multiply_1x4_2(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s,
                          int length)
{
    auto hi = vdupq_n_u64(0);
    auto lo = vdupq_n_u64(0);
    for (int i = 0; i < length; i += 8) {
        auto x1 = vld4q_u64(&x1s[i]);
        auto x2 = vld4q_u64(&x2s[i]);
        auto x1_1 = x1.val[0];
        auto x1_2 = x1.val[1];
        auto x1_3 = x1.val[2];
        auto x1_4 = x1.val[3];
        auto x2_1 = x2.val[0];
        auto x2_2 = x2.val[1];
        auto x2_3 = x2.val[2];
        auto x2_4 = x2.val[2];
        vst4q_u64(&x1s[i], (uint64x2x4_t{ x1_1 | x2_1, x1_2 | x2_2,
                    x1_3 | x2_3, x1_4 | x2_4 }));

        auto z1 = vld4q_u64(&z1s[i]);
        auto z2 = vld4q_u64(&z2s[i]);
        auto z1_1 = z1.val[0];
        auto z1_2 = z1.val[1];
        auto z1_3 = z1.val[2];
        auto z1_4 = z1.val[3];
        auto z2_1 = z2.val[0];
        auto z2_2 = z2.val[1];
        auto z2_3 = z2.val[2];
        auto z2_4 = z2.val[2];
        vst4q_u64(&z1s[i], (uint64x2x4_t{ z1_1 | z2_1, z1_2 | z2_2,
                    z1_3 | z2_3, z1_4 | z2_4 }));

        auto v1_1 = x1_1 & z2_1;
        auto v1_2 = x1_2 & z2_2;
        auto v1_3 = x1_3 & z2_3;
        auto v1_4 = x1_4 & z2_4;
        auto v2_1 = x2_1 & z1_1;
        auto v2_2 = x2_2 & z1_2;
        auto v2_3 = x2_3 & z1_3;
        auto v2_4 = x2_4 & z1_4;
        auto m_1 = (z2_1 ^ x1_1) | ~(x2_1 | z1_1);
        auto m_2 = (z2_2 ^ x1_2) | ~(x2_2 | z1_2);
        auto m_3 = (z2_3 ^ x1_3) | ~(x2_3 | z1_3);
        auto m_4 = (z2_4 ^ x1_4) | ~(x2_4 | z1_4);
        auto change_1 = v1_1 ^ v2_1;
        auto change_2 = v1_2 ^ v2_2;
        auto change_3 = v1_3 ^ v2_3;
        auto change_4 = v1_4 ^ v2_4;
        hi = hi ^ ((m_1 ^ lo) & change_1);
        lo = lo ^ change_1;
        hi = hi ^ ((m_2 ^ lo) & change_2);
        lo = lo ^ change_2;
        hi = hi ^ ((m_3 ^ lo) & change_3);
        lo = lo ^ change_3;
        hi = hi ^ ((m_4 ^ lo) & change_4);
        lo = lo ^ change_4;
    }
    auto cnt_lo = vcntq_u8((uint8x16_t)lo);
    auto cnt_hi = vcntq_u8((uint8x16_t)hi);
    cnt_hi = vshlq_n_u8(cnt_hi, 1);
    auto cnt = cnt_lo + cnt_hi;
    return vaddvq_u8(cnt) & 3;
}

static int multiply_2(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s, int length)
{
    auto cm = vdupq_n_u8(0);
    auto cp = vdupq_n_u8(0);
    for (int i = 0; i < length; i += 2) {
        auto x1 = vld1q_u64(&x1s[i]);
        auto x2 = vld1q_u64(&x2s[i]);
        vst1q_u64(&x1s[i], x1 ^ x2);

        auto z1 = vld1q_u64(&z1s[i]);
        auto z2 = vld1q_u64(&z2s[i]);
        vst1q_u64(&z1s[i], z1 ^ z2);

        auto v1 = x1 & z2;
        auto v2 = x2 & z1;
        auto change = v1 ^ v2;
        auto m = (z2 ^ x1) | ~(x2 | z1);
        cm += vcntq_u8((uint8x16_t)(m & change));
        cp += vcntq_u8((uint8x16_t)(~m & change));
    }
    auto cnt = cp - cm;
    return vaddvq_u8(cnt) & 3;
}

static int multiply_2_2(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s, int length)
{
    auto cnt = vdupq_n_u8(0);
    for (int i = 0; i < length; i += 2) {
        auto x1 = vld1q_u64(&x1s[i]);
        auto x2 = vld1q_u64(&x2s[i]);
        vst1q_u64(&x1s[i], x1 ^ x2);

        auto z1 = vld1q_u64(&z1s[i]);
        auto z2 = vld1q_u64(&z2s[i]);
        vst1q_u64(&z1s[i], z1 ^ z2);

        auto v1 = x1 & z2;
        auto v2 = x2 & z1;
        auto change = v1 ^ v2;
        auto m = (z2 ^ x1) | ~(x2 | z1);
        cnt += vcntq_u8((uint8x16_t)(~m & change));
        cnt -= vcntq_u8((uint8x16_t)(m & change));
    }
    return vaddvq_u8(cnt) & 3;
}

static int multiply_3(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s, int length)
{
    uint8_t cm = 0;
    uint8_t cp = 0;
    for (int i = 0; i < length; i += 2) {
        auto x1 = vld1q_u64(&x1s[i]);
        auto x2 = vld1q_u64(&x2s[i]);
        vst1q_u64(&x1s[i], x1 ^ x2);

        auto z1 = vld1q_u64(&z1s[i]);
        auto z2 = vld1q_u64(&z2s[i]);
        vst1q_u64(&z1s[i], z1 ^ z2);

        auto v1 = x1 & z2;
        auto v2 = x2 & z1;
        auto change = v1 ^ v2;
        auto m = (z2 ^ x1) | ~(x2 | z1);
        cm += vaddvq_u8(vcntq_u8((uint8x16_t)(m & change)));
        cp += vaddvq_u8(vcntq_u8((uint8x16_t)(~m & change)));
    }
    return (cp - cm) & 3;
}

static int multiply_3_2(uint64_t *x1s, uint64_t *z1s, uint64_t *x2s, uint64_t *z2s, int length)
{
    uint8_t cnt = 0;
    for (int i = 0; i < length; i += 2) {
        auto x1 = vld1q_u64(&x1s[i]);
        auto x2 = vld1q_u64(&x2s[i]);
        vst1q_u64(&x1s[i], x1 ^ x2);

        auto z1 = vld1q_u64(&z1s[i]);
        auto z2 = vld1q_u64(&z2s[i]);
        vst1q_u64(&z1s[i], z1 ^ z2);

        auto v1 = x1 & z2;
        auto v2 = x2 & z1;
        auto change = v1 ^ v2;
        auto m = (z2 ^ x1) | ~(x2 | z1);
        cnt += vaddvq_u8(vcntq_u8((uint8x16_t)(~m & change)));
        cnt -= vaddvq_u8(vcntq_u8((uint8x16_t)(m & change)));
    }
    return cnt & 3;
}

using fptr_t = void (*)(void);

struct function {
    const char *name;
    fptr_t fptr;
};

#define fele(name) { #name, fptr_t(name) }

#ifdef __clang__
#define COMPILER_VERSION __VERSION__
#else
// Yes i know...
#define COMPILER_VERSION "GCC " __VERSION__
#endif

#if defined(__aarch64__)
#define ARCH_NAME "aarch64"
#elif defined(__x86_64__)
#define ARCH_NAME "x86_64"
#elif defined(__x86__)
#define ARCH_NAME "x86"
#else
#define ARCH_NAME "unknown"
#endif

const char *version = COMPILER_VERSION " " ARCH_NAME;
function functions[] = {
    fele(multiply_0),
    fele(multiply_1),
    fele(multiply_1x2_1),
    fele(multiply_1x2_2),
    fele(multiply_1x4_1),
    fele(multiply_1x4_2),
    fele(multiply_2),
    fele(multiply_2_2),
    fele(multiply_3),
    fele(multiply_3_2),
    {nullptr, nullptr}
};

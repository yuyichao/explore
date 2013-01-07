#include "lib.h"

int
simple_return(int i)
{
    return i;
}

int
memcpy_return(int i)
{
    int __tmp1;
    int __tmp2;
    int __tmp3;
    int __tmp4;
    int __tmp5;
    int __tmp6;
    int __tmp7;
    int __tmp8;
    int __tmp9;
    int __tmp10;
    int __tmp11;
    int __tmp12;
    memcpy(&__tmp1, &i, sizeof(i));
    memcpy(&__tmp2, &__tmp1, sizeof(i));
    memcpy(&__tmp3, &__tmp2, sizeof(i));
    memcpy(&__tmp4, &__tmp3, sizeof(i));
    memcpy(&__tmp5, &__tmp4, sizeof(i));
    memcpy(&__tmp6, &__tmp5, sizeof(i));
    memcpy(&__tmp7, &__tmp6, sizeof(i));
    memcpy(&__tmp8, &__tmp7, sizeof(i));
    memcpy(&__tmp9, &__tmp8, sizeof(i));
    memcpy(&__tmp10, &__tmp9, sizeof(i));
    memcpy(&__tmp11, &__tmp10, sizeof(i));
    memcpy(&__tmp12, &__tmp11, sizeof(i));
    return __tmp12;
}

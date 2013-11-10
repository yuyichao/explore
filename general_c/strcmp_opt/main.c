#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>

#ifdef NDEBUG
#  undef NDEBUG
#endif
#include <assert.h>

#define N 10000000

//#define CLOCK_ID CLOCK_PROCESS_CPUTIME_ID
#define CLOCK_ID CLOCK_MONOTONIC

int _global_;

#define KEY1 "A"
#define VALUE1 "B"
#define KEY2 "alks;jdflaksd"
#define VALUE2 "ijqwj8f908qje098fjasjdfad"
#define KEY3 "jjjj"
#define VALUE3 "jaisodjpfoaisjdpfspjoiajsd"
#define KEY4 "lajpsoidjfpaoisjdf9a8098j"
#define VALUE4 "kaj;slkdjfp48j098jasoidjfasdad"
#define KEY5 "japisd"
#define VALUE5 "0./askjfdap9isdf"
#define KEY6 "aj8s9fasdf"
#define VALUE6 "akjsdpjaisdf"
#define KEY7 "akjsdpofaids"
#define VALUE7 "984uuajsdf"
#define KEY8 "90asdifasdfjads9ifja98sjdfa"
#define VALUE8 "9iujfalksjdfaifjalkdsjfajsf489g"

__attribute__((always_inline)) static inline const char*
str_switch(const char *str)
{
    if (strcmp(str, KEY1) == 0) {
        return VALUE1;
    } else if (strcmp(str, KEY2) == 0) {
        return VALUE2;
    } else if (strcmp(str, KEY3) == 0) {
        return VALUE3;
    } else if (strcmp(str, KEY4) == 0) {
        return VALUE4;
    } else if (strcmp(str, KEY5) == 0) {
        return VALUE5;
    } else if (strcmp(str, KEY6) == 0) {
        return VALUE6;
    } else if (strcmp(str, KEY7) == 0) {
        return VALUE7;
    } else if (strcmp(str, KEY8) == 0) {
        return VALUE8;
    }
    return NULL;
}

int
main()
{
    const char *res;

    res = str_switch(KEY1);
    printf("%s", res);
    assert(strcmp(res, VALUE1) == 0);

    res = str_switch(KEY2);
    printf("%s", res);
    assert(strcmp(res, VALUE2) == 0);

    res = str_switch(KEY3);
    printf("%s", res);
    assert(strcmp(res, VALUE3) == 0);

    res = str_switch(KEY4);
    printf("%s", res);
    assert(strcmp(res, VALUE4) == 0);

    res = str_switch(KEY5);
    printf("%s", res);
    assert(strcmp(res, VALUE5) == 0);

    res = str_switch(KEY6);
    printf("%s", res);
    assert(strcmp(res, VALUE6) == 0);

    res = str_switch(KEY7);
    printf("%s", res);
    assert(strcmp(res, VALUE7) == 0);

    res = str_switch(KEY8);
    printf("%s", res);
    assert(strcmp(res, VALUE8) == 0);

    res = str_switch("");
    printf("%s", res);
    assert(res == NULL);

    return res != NULL;
}

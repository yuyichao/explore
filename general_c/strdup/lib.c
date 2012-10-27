#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char*
my_strdup(const char *str)
{
    return strdup(str);
}

char*
my_strndup0(const char *str, size_t n)
{
    return strndup(str, n);
}

char*
my_strndup1(const char *str, size_t n)
{
    char *res = malloc(n + 1);
    memcpy(res, str, n);
    res[n] = '\0';
    return res;
}

char*
my_strndup2(const char *str, size_t n)
{
    char *res = realloc(NULL, n + 1);
    memcpy(res, str, n);
    res[n] = '\0';
    return res;
}

char*
my_setstr(char *res, const char *str, size_t n)
{
    res = realloc(res, n + 1);
    memcpy(res, str, n);
    res[n] = '\0';
    return res;
}

char*
my_setstr2(char *res, const char *str, size_t n)
{
    if (res) {
        res = realloc(res, n + 1);
    } else {
        res = malloc(n + 1);
    }
    memcpy(res, str, n);
    res[n] = '\0';
    return res;
}

char*
nop(char *res, const char *str, size_t n)
{
    return NULL;
}

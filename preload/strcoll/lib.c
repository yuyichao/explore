#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static void *handle = NULL;

int
(strcoll)(const char *s1, const char *s2)
{
    static int (*libfunc)(const char *s1, const char *s2) = NULL;
    char *error;
    if (!libfunc) {
        if (!handle) {
            handle = dlopen("/usr/lib/libc.so.6", RTLD_NOW);
            if (!handle) {
                fputs(dlerror(), stderr);
                exit(1);
            }
        }
        libfunc = dlsym(handle, __func__);
        if ((error = dlerror()) != NULL) {
            fprintf(stderr, "%s\n", error);
            exit(1);
        }
    }
    int res = libfunc(s1, s2);
    fprintf(stderr, "calling %s, with %s and %s, return %d\n",
            __func__, s1, s2, res);
    return res;
}

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

void
test_vaarg(unsigned int size0, ...)
{
    va_list ap;
    unsigned int size;
    size = size0;

    va_start(ap, size0);
    while (size) {
        typedef struct {
            char s[size];
        } value;
        value v;
        printf("size: %u, rsize: %u\n", size, (unsigned int)sizeof(value));
        v = va_arg(ap, value);
        size = va_arg(ap, unsigned int);
    }
    va_end(ap);
}

int
main()
{
    test_vaarg(sizeof(int), 1234, sizeof(char*), "asdf", sizeof(char), 'a',
               sizeof(char), 'b', sizeof(char*), "", sizeof(int), 12341234);
    return 0;
}

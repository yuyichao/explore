#include <qglobal.h>
#include <stdarg.h>
#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>

int _Xdebug = 1;

static int count = 1;

void
(qWarning)(const char *msg, ...)
{
    if (count++ > 10) {
        abort();
    }
    void *buff[1024];
    size_t size = backtrace(buff, 1024);
    backtrace_symbols_fd(buff, size, 2);
    va_list ap;
    va_start(ap, msg); // use variable arg list
    vprintf(msg, ap);
    va_end(ap);
}

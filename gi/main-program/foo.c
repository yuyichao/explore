#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#include "foo.h"
#include <glib.h>
#include <gjs/gjs.h>
#include <girepository.h>

/**
 * foo_hello:
 * @str: (allow-none) (transfer none):
 *
 * test
 */
void
foo_hello(const char *str)
{
    printf("%s, %s\n", __func__, str);
}

int
main(int argc, char **argv)
{
    g_type_init();
    Py_Initialize();
    char *js_path[2] = { 0 };
    js_path[0] = getenv("JS_PATH");
    wchar_t *v[] = {};

    GOptionContext *ctx = g_option_context_new(NULL);
    g_option_context_add_group(ctx, g_irepository_get_option_group());
    g_option_context_parse(ctx, &argc, &argv, NULL);
    PySys_SetArgv(0, v);

    PyRun_SimpleString("from time import time, ctime\n"
                       "print('Today is', ctime(time()))\n");
    GjsContext *gjs_ctx = gjs_context_new_with_search_path(js_path);
    gjs_context_eval(gjs_ctx, "const Main = imports.main; Main.start();",
                     -1, "<main>", NULL, NULL);
    PyRun_SimpleString("from gi.repository import Foo\n"
                       "Foo.hello('python')\n");
    FILE *py_file;
    const char *py_fname = getenv("PYTHON_FILE");
    py_file = fopen(py_fname, "r");
    PyRun_SimpleFile(py_file, py_fname);
    Py_Finalize();
    return 0;
}

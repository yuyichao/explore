#include <gtk/gtk.h>
#include <dlfcn.h>
#include <stdlib.h>

static void *handle = NULL;

gboolean
gtk_im_context_filter_keypress(GtkIMContext *context, GdkEventKey *key)
{
    static gboolean (*libfunc)(GtkIMContext*, GdkEventKey*) = NULL;
    char *error;
    if (!libfunc) {
        if (!handle) {
            handle = dlopen("/usr/lib/libgtk-x11-2.0.so", RTLD_LAZY);
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
    fprintf(stderr, "calling %s\n", __func__);
    return libfunc(context, key);
}

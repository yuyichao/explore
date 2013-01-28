#include <gtk/gtk.h>
#include <dlfcn.h>
#include <stdlib.h>

static void *handle = NULL;

void
gtk_main()
{
    static void (*libfunc)() = NULL;
    char *error;
    if (!libfunc) {
        if (!handle) {
            handle = dlopen("/usr/lib/libgtk-x11-2.0.so", RTLD_NOW);
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
    printf("%s\n", __func__);
    libfunc();
}

void
print_gdkeventkey(GdkEventKey *event)
{
    fprintf(stderr,
            "type: %d\n"
            "send_event: %s\n"
            "time: %d\n"
            "state: %d\n"
            "keyval: %d\n"
            "string: %s\n"
            "hardware_keycode: %d\n"
            "group: %d\n"
            "is_modifier: %s\n",
            (int)event->type,
            event->send_event ? "true" : "false",
            (int)event->time,
            (int)event->state,
            (int)event->keyval,
            event->string,
            (int)event->hardware_keycode,
            (int)event->group,
            event->is_modifier ? "true" : "false");
}

gboolean
gtk_window_activate_key(GtkWindow *window, GdkEventKey *event)
{
    static gboolean (*libfunc)(GtkWindow *window, GdkEventKey *event) = NULL;
    char *error;
    if (!libfunc) {
        if (!handle) {
            handle = dlopen("/usr/lib/libgtk-x11-2.0.so", RTLD_NOW);
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
    print_gdkeventkey(event);
    return libfunc(window, event);
}

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <gdk/gdk.h>
#include <dlfcn.h>

static GdkEventFunc real_event_handler = NULL;

static void
print_keyevent(GdkEventKey *kevent)
{
    printf("%s: ", kevent->type == GDK_KEY_PRESS ? "press" : "release");
    printf("from %lx\n", (gulong)kevent->window);
    printf("send: %s, ", kevent->send_event ? "true" : "false");
    printf("time: %u\n", kevent->time);
    printf("state: %u, ", kevent->state);
    printf("keyval: %u, ", kevent->keyval);
    printf("hardware_keycode: %u, ", (guint)kevent->hardware_keycode);
    printf("is_modifier: %s\n\n", kevent->is_modifier ? "true" : "false");
}

static void
event_proxy(GdkEvent *event, gpointer data)
{
    if (event->type == GDK_KEY_PRESS || event->type == GDK_KEY_RELEASE) {
        print_keyevent((GdkEventKey*)event);
    }
    if (real_event_handler)
        real_event_handler(event, data);
}

void
gdk_event_handler_set(GdkEventFunc func, gpointer data, GDestroyNotify notify)
{
    printf("%s\n", __func__);
    static void *handle = NULL;
    static void (*lib_function)(GdkEventFunc func, gpointer data,
                                GDestroyNotify notify) = NULL;
    if (!handle) {
        handle = dlopen("libgdk-3.so", RTLD_LAZY);
        if (!handle) {
            fputs(dlerror(), stderr);
            exit(1);
        }
    }
    if (!lib_function) {
        lib_function = dlsym(handle, __func__);
        if (!lib_function) {
            fputs(dlerror(), stderr);
            exit(1);
        }
    }
    real_event_handler = func;
    lib_function(event_proxy, data, notify);
}

#include <glib.h>
#include <gdk/gdk.h>

GMainLoop *mainloop;

static void event_func(GdkEvent *ev, gpointer data)
{
    switch(ev->type) {
    case GDK_NOTHING:
    case GDK_DELETE:
        g_printf("delete\n");
        g_main_loop_quit(mainloop);
        break;
    case GDK_DESTROY:
        g_printf("destroy\n");
        break;
    case GDK_EXPOSE:
        g_printf("expose\n");
        break;
    case GDK_MOTION_NOTIFY:
        g_printf("motion-notify\n");
        break;
    case GDK_BUTTON_PRESS:
        g_printf("button-press\n");
        break;
    case GDK_2BUTTON_PRESS:
        g_printf("2button-press\n");
        break;
    case GDK_3BUTTON_PRESS:
        g_printf("3button-press\n");
        break;
    case GDK_BUTTON_RELEASE:
        g_printf("button-release\n");
        break;
    case GDK_KEY_PRESS:
        g_printf("key-press\n");
        g_printf("send_event: %d\n", (gint)ev->key.send_event);
        g_printf("time: %d\n", (gint)ev->key.time);
        g_printf("state: %x\n", (gint)ev->key.state);
        g_printf("keyval: %x\n", (gint)ev->key.keyval);
        g_printf("length: %d\n", (gint)ev->key.length);
        g_printf("string: %s\n", ev->key.string);
        g_printf("hardware_keycode: %x\n", (gint)ev->key.hardware_keycode);
        g_printf("group: %d\n", (gint)ev->key.group);
        g_printf("is_modifier: %d\n", (gint)ev->key.is_modifier);
        break;
    case GDK_KEY_RELEASE:
        g_printf("key-release\n");
        break;
    case GDK_ENTER_NOTIFY:
        g_printf("enter-notify\n");
        break;
    case GDK_LEAVE_NOTIFY:
        g_printf("leave-notify\n");
        break;
    case GDK_FOCUS_CHANGE:
        g_printf("focus-change\n");
        break;
    case GDK_CONFIGURE:
        g_printf("configure\n");
        break;
    case GDK_MAP:
        g_printf("map\n");
        break;
    case GDK_UNMAP:
        g_printf("unmap\n");
        break;
    case GDK_PROPERTY_NOTIFY:
        g_printf("property-notify\n");
        break;
    case GDK_SELECTION_CLEAR:
        g_printf("selection-clear\n");
        break;
    case GDK_SELECTION_REQUEST:
        g_printf("selection-request\n");
        break;
    case GDK_SELECTION_NOTIFY:
        g_printf("selection-notify\n");
        break;
    case GDK_PROXIMITY_IN:
        g_printf("proximity-in\n");
        break;
    case GDK_PROXIMITY_OUT:
        g_printf("proximity-out\n");
        break;
    case GDK_DRAG_ENTER:
        g_printf("drag-enter\n");
        break;
    case GDK_DRAG_LEAVE:
        g_printf("drag-leave\n");
        break;
    case GDK_DRAG_MOTION:
        g_printf("drag-motion\n");
        break;
    case GDK_DRAG_STATUS:
        g_printf("drag-status\n");
        break;
    case GDK_DROP_START:
        g_printf("drop-start\n");
        break;
    case GDK_DROP_FINISHED:
        g_printf("drop-finished\n");
        break;
    case GDK_CLIENT_EVENT:
        g_printf("client-event\n");
        break;
    case GDK_VISIBILITY_NOTIFY:
        g_printf("visibility-notify\n");
        break;
    case GDK_SCROLL:
        g_printf("scroll\n");
        break;
    case GDK_WINDOW_STATE:
        g_printf("window-state\n");
        break;
    case GDK_SETTING:
        g_printf("setting\n");
        break;
    case GDK_OWNER_CHANGE:
        g_printf("owner-change\n");
        break;
    case GDK_GRAB_BROKEN:
        g_printf("grab-broken\n");
        break;
    case GDK_DAMAGE:
        g_printf("damage\n");
        break;
    case GDK_EVENT_LAST:
    default:
        g_printf("last\n");
        break;
    }
}

int main(int argc, char **argv)
{
    gdk_init(&argc, &argv);

    GdkWindowAttr attr;
    attr.title = argv[0];
    attr.event_mask = GDK_KEY_PRESS_MASK | GDK_STRUCTURE_MASK |
        GDK_EXPOSURE_MASK;
    attr.window_type = GDK_WINDOW_TOPLEVEL;
    attr.wclass = GDK_INPUT_OUTPUT;
    attr.width = 400;
    attr.height = 300;
    GdkWindow *win = gdk_window_new(NULL, &attr, 0);

    gdk_window_show(win);

    gdk_event_handler_set(event_func, NULL, NULL);
    // this is used by GTK+ internally. We just use it for ourselves here

    mainloop = g_main_loop_new(g_main_context_default(), FALSE);
    // we use the default main context because that's what GDK uses internally
    g_main_loop_run(mainloop);

    gdk_window_destroy(win);

    return 0;
}

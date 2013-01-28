#include <gtk/gtk.h>
#include <stdint.h>

static void
print_parse_accel(const char *accel_str)
{
    guint accel_key;
    GdkModifierType accel_mod;

    gtk_accelerator_parse(accel_str, &accel_key, &accel_mod);
    printf("%s, str: %s, key: %d, mod: %d\n",
           __func__, accel_str, accel_key, accel_mod);

    gchar *name;
    name = gtk_accelerator_name(accel_key, accel_mod);
    printf("%s, name: %s\n", __func__, name);
    g_free(name);

    name = gtk_accelerator_get_label(accel_key, accel_mod);
    printf("%s, name: %s\n\n", __func__, name);
    g_free(name);
}

static gboolean
accel_activate_cb(GtkAccelGroup *accel_group, GObject *acceleratable,
                  guint keyval, GdkModifierType modifier, void *data)
{
    const char *key_name = data;
    printf("%s, val: %d, mod: %d, name: %s\n",
           __func__, keyval, modifier, key_name);
    return FALSE;
}

static void
connect_accel(GtkAccelGroup *accel_group, const char *key)
{
    guint accel_key;
    GdkModifierType accel_mod;
    gtk_accelerator_parse(key, &accel_key, &accel_mod);
    GClosure *closure;
    closure = g_cclosure_new(G_CALLBACK(accel_activate_cb),
                             (void*)(intptr_t)key, NULL);
    gtk_accel_group_connect(accel_group,
                            accel_key,
                            accel_mod,
                            GTK_ACCEL_VISIBLE | GTK_ACCEL_LOCKED,
                            closure);
    g_closure_unref(closure);
}

static void
accel_changed_cb(GtkAccelGroup *accel_group, guint keyval,
                 GdkModifierType modifier, GClosure *accel_closure,
                 gpointer user_data)
{
    printf("%s, val: %d, mod: %d\n",
           __func__, keyval, modifier);
}

int
main()
{
    gtk_init(0, NULL);

    print_parse_accel("<Control>a");
    print_parse_accel("<Control>b");
    print_parse_accel("<Control>c");
    print_parse_accel("<Control>d");
    print_parse_accel("<Control>e");

    print_parse_accel("<Primary>a");
    print_parse_accel("<Primary>b");
    print_parse_accel("<Primary>c");
    print_parse_accel("<Primary>d");
    print_parse_accel("<Primary>e");

    GtkWidget *window;
    GtkAccelGroup *accel_group = NULL;

    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    g_signal_connect(window, "destroy", gtk_main_quit, NULL);

    accel_group = gtk_accel_group_new();
    g_signal_connect(accel_group, "accel-activate",
                     G_CALLBACK(accel_activate_cb), "General");
    g_signal_connect(accel_group, "accel-changed",
                     G_CALLBACK(accel_changed_cb), NULL);
    gtk_window_add_accel_group(GTK_WINDOW(window), accel_group);

    connect_accel(accel_group, "<Control>a");
    connect_accel(accel_group, "<Control>b");
    connect_accel(accel_group, "<Control>c");
    connect_accel(accel_group, "<Control>d");
    connect_accel(accel_group, "<Control>e");

    connect_accel(accel_group, "<Alt>a");
    connect_accel(accel_group, "<Alt>b");
    connect_accel(accel_group, "<Alt>c");
    connect_accel(accel_group, "<Alt>d");
    connect_accel(accel_group, "<Alt>e");

    connect_accel(accel_group, "<Control><Alt>a");
    connect_accel(accel_group, "<Control><Alt>b");
    connect_accel(accel_group, "<Control><Alt>c");
    connect_accel(accel_group, "<Control><Alt>d");
    connect_accel(accel_group, "<Control><Alt>e");

    gtk_widget_show_all(window);
    gtk_main();
    return 0;
}


#include <glib.h>
#include <gio/gio.h>
#include <glib/gstdio.h>
#include <glib/gprintf.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>

static void on_bus_acquired(GDBusConnection *connection, const gchar *name,
			    gpointer p)
{
	g_print("a\n");
};

static void on_name_lost(GDBusConnection *connection, const gchar *name,
			   gpointer p)
{
	g_print("lost\n");
};

static void on_name_acquired(GDBusConnection *connection, const gchar *name,
			   gpointer p)
{
	g_print("ac\n");
};

int main()
{
	GMainLoop *loop = g_main_loop_new(NULL, FALSE);
	g_type_init();
	g_bus_own_name(G_BUS_TYPE_SYSTEM, "org.freedesktop.PolicyKit1", G_BUS_NAME_OWNER_FLAGS_ALLOW_REPLACEMENT|G_BUS_NAME_OWNER_FLAGS_REPLACE, on_bus_acquired, on_name_acquired, on_name_lost, NULL, NULL);
	g_main_loop_run(loop);
}

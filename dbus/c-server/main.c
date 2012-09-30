#include <gio/gio.h>
#include <stdlib.h>
#include <stdio.h>
#include <gio/gunixfdlist.h>
#include <unistd.h>

static GDBusNodeInfo *introspection_data = NULL;
static gchar *BusName = "org.gtk.GDBus.TestServer";
static gchar *ObjPath = "/org/gtk/GDBus/TestObject";
static const gchar introspection_xml[] =
	"<node>"
	"  <interface name='org.gtk.GDBus.TestInterface'>"
	"    <method name='HelloWorld'>"
	"      <arg type='s' name='greeting' direction='in'/>"
	"      <arg type='s' name='response' direction='out'/>"
	"    </method>"
	"    <signal name='VelocityChanged'>"
	"      <arg type='d' name='speed_in_mph'/>"
	"      <arg type='s' name='speed_as_string'/>"
	"    </signal>"
	"    <property type='s' name='Title' access='readwrite'/>"
	"  </interface>"
	"</node>";

static void handle_method_call(GDBusConnection *connection,
			       const gchar *sender,
			       const gchar *object_path,
			       const gchar *interface_name,
			       const gchar *method_name,
			       GVariant *parameters,
			       GDBusMethodInvocation *invocation,
			       gpointer user_data)
{
	printf("call method: '%s'\n", method_name);
	if (!g_strcmp0(method_name, "HelloWorld")) {
		const gchar *greeting;
		g_variant_get(parameters, "(&s)", &greeting);
		gchar *response;
		response = g_strdup_printf("You greeted me with '%s'. Thanks!", greeting);
		g_dbus_method_invocation_return_value
			(invocation, g_variant_new("(s)", response));
		g_free (response);
	} else {
		g_dbus_method_invocation_return_dbus_error(invocation,
							   "org.gtk.GDBus.Failed",
							   "Your message bus daemon does not support file descriptor passing (need D-Bus >= 1.3.0)");
		}
}

static gchar *_global_title = NULL;

static gboolean swap_a_and_b = FALSE;

static GVariant* handle_get_property(GDBusConnection *connection,
				     const gchar *sender,
				     const gchar *object_path,
				     const gchar *interface_name,
				     const gchar *property_name,
				     GError **error,
				     gpointer user_data)
{
	GVariant *ret;
	printf("get property: '%s'\n", property_name);
	ret = NULL;
	if (!g_strcmp0(property_name, "Title")) {
		if (_global_title == NULL)
			_global_title = g_strdup("Back To C!");
		ret = g_variant_new_string(_global_title);
	}
	return ret;
}

static gboolean handle_set_property (GDBusConnection *connection,
				     const gchar *sender,
				     const gchar *object_path,
				     const gchar *interface_name,
				     const gchar *property_name,
				     GVariant *value,
				     GError **error,
				     gpointer user_data)
{
	printf("set property: '%s'\n", property_name);
	if (!g_strcmp0(property_name, "Title")) {
		if (g_strcmp0(_global_title, g_variant_get_string (value, NULL))) {
			GVariantBuilder *builder;
			GError *local_error;
			g_free(_global_title);
			_global_title = g_variant_dup_string(value, NULL);

			local_error = NULL;
			builder = g_variant_builder_new(G_VARIANT_TYPE_ARRAY);
			g_variant_builder_add
				(builder, "{sv}", "Title",
				 g_variant_new_string(_global_title));
			g_dbus_connection_emit_signal
				(connection, NULL, object_path,
				 "org.freedesktop.DBus.Properties",
				 "PropertiesChanged",
				 g_variant_new("(sa{sv}as)", interface_name,
					       builder, NULL),
				 &local_error);
			g_assert_no_error (local_error);
		}
	}

	return *error == NULL;
}


static const GDBusInterfaceVTable interface_vtable = {
	handle_method_call,
	handle_get_property,
	handle_set_property
};


static void on_bus_acquired(GDBusConnection *connection,
			    const gchar *name,
			    gpointer user_data)
{
	guint registration_id;

	registration_id = g_dbus_connection_register_object
		(connection, ObjPath, introspection_data->interfaces[0],
		 &interface_vtable, NULL, NULL, NULL);
	g_assert(registration_id > 0);

	printf("bus acquired: %d\n", registration_id);
}

static void on_name_acquired(GDBusConnection *connection,
			     const gchar *name,
			     gpointer user_data)
{
	printf("name: '%s' got.\n", name);
}

static void on_name_lost(GDBusConnection *connection,
			 const gchar *name,
			 gpointer user_data)
{
	printf("name: '%s' is lost.\n", name);
	exit (1);
}

int main()
{
	guint owner_id;
	GMainLoop *loop;

	g_type_init();

	introspection_data = g_dbus_node_info_new_for_xml(introspection_xml, NULL);
	g_assert(introspection_data != NULL);

	owner_id = g_bus_own_name
		(G_BUS_TYPE_SESSION, BusName, G_BUS_NAME_OWNER_FLAGS_NONE,
		 on_bus_acquired, on_name_acquired, on_name_lost, NULL, NULL);

	loop = g_main_loop_new(NULL, FALSE);
	g_main_loop_run(loop);

	g_bus_unown_name(owner_id);

	g_dbus_node_info_unref(introspection_data);

	return 0;
}

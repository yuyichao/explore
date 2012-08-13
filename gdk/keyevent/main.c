#include <webkit/webkit.h>
#include <JavaScriptCore/JavaScript.h>
#include <gtk/gtk.h>

int
main()
{
    gtk_init(NULL, NULL);
    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    GtkWidget *web_view = webkit_web_view_new();
    gtk_container_add(GTK_CONTAINER(window), web_view);
    gtk_widget_show_all(window);
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);
    gchar *cwd = g_get_current_dir();
    printf("%s\n", cwd);
    gchar *path = g_build_filename(cwd, "index.html", NULL);
    gchar *start = g_filename_to_uri(path, NULL, NULL);
    webkit_web_view_load_uri(WEBKIT_WEB_VIEW(web_view), start);

    g_free(cwd);
    g_free(path);
    g_free(start);

    gtk_main();
    return 0;
}

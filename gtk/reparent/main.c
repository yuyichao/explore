#include <gtk/gtk.h>

GtkWidget *parent = NULL;
GtkWidget *not_parent = NULL;

void clicked_cb(GtkWidget *button, gpointer p)
{
    GtkWidget *tmp = parent;
    parent = not_parent;
    not_parent = tmp;

    gtk_widget_reparent(button, parent);
}

int main()
{
    gtk_init(NULL, NULL);

    GtkWidget *window1 = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    GtkWidget *window2 = gtk_window_new(GTK_WINDOW_TOPLEVEL);

    gtk_window_set_default_size(GTK_WINDOW(window1), 100, 100);
    gtk_window_set_default_size(GTK_WINDOW(window2), 100, 100);

    GtkWidget *button = gtk_button_new_with_label("asdf");

    gtk_container_add(GTK_CONTAINER(window1), button);

    parent = window1;
    not_parent = window2;

    g_signal_connect(window1, "destroy", G_CALLBACK(gtk_main_quit), NULL);
    g_signal_connect(window2, "destroy", G_CALLBACK(gtk_main_quit), NULL);
    g_signal_connect(button, "clicked", G_CALLBACK(clicked_cb), NULL);

    gtk_widget_show_all(window1);
    gtk_widget_show_all(window2);

    gtk_main();
}

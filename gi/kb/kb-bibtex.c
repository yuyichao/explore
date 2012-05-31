#include "kb-bibtex.h"

G_DEFINE_TYPE (KbBibtex, kb_bibtex, G_TYPE_OBJECT);

#define KB_BIBTEX_GET_PRIVATE(object) (                                 \
        G_TYPE_INSTANCE_GET_PRIVATE ((object), KB_TYPE_BIBTEX, KbBibtexPrivate))

typedef struct _KbBibtexPrivate KbBibtexPrivate;
struct _KbBibtexPrivate {
    GString *title;
    GString *author;
    GString *publisher;
    guint   year;
};

enum PROPERTY_BIBTEX {
    PROPERTY_0,
    PROPERTY_TITLE,
    PROPERTY_AUTHOR,
    PROPERTY_PUBLISHER,
    PROPERTY_YEAR,
    N_PROPERTIES
};

static void
kb_bibtex_set_property (GObject *object, guint property_id,
                        const GValue *value, GParamSpec *pspec)
{
    KbBibtex *self = KB_BIBTEX (object);
    KbBibtexPrivate *priv = KB_BIBTEX_GET_PRIVATE (self);

    switch (property_id) {
    case PROPERTY_TITLE:
        if (priv->title)
            g_string_free (priv->title, TRUE);
        priv->title = g_string_new (g_value_get_string (value));
        break;
    case PROPERTY_AUTHOR:
        if (priv->author)
            g_string_free (priv->author, TRUE);
        priv->author = g_string_new (g_value_get_string (value));
        break;
    case PROPERTY_PUBLISHER:
        if (priv->publisher)
            g_string_free (priv->publisher, TRUE);
        priv->publisher = g_string_new (g_value_get_string (value));
        break;
    case PROPERTY_YEAR:
        priv->year = g_value_get_uint (value);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
        break;
    }
}

static void
kb_bibtex_get_property (GObject *object, guint property_id,
                        GValue *value, GParamSpec *pspec)
{
    KbBibtex *self = KB_BIBTEX (object);
    KbBibtexPrivate *priv = KB_BIBTEX_GET_PRIVATE (self);
    GString *similar = NULL;

    switch (property_id) {
    case PROPERTY_TITLE:
        g_value_set_string (value, priv->title->str);
        break;
    case PROPERTY_AUTHOR:
        g_value_set_string (value, priv->author->str);
        break;
    case PROPERTY_PUBLISHER:
        g_value_set_string (value, priv->publisher->str);
        break;
    case PROPERTY_YEAR:
        g_value_set_uint (value, priv->year);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
        break;
    }
}

static void
kb_bibtex_init (KbBibtex *self)
{
}

static void
kb_bibtex_class_init (KbBibtexClass *klass)
{
    g_type_class_add_private (klass, sizeof (KbBibtexPrivate));

    GObjectClass *base_class = G_OBJECT_CLASS (klass);
    base_class->set_property = kb_bibtex_set_property;
    base_class->get_property = kb_bibtex_get_property;
    GParamSpec *properties[N_PROPERTIES] = {NULL,};
    properties[PROPERTY_TITLE] =
        g_param_spec_string ("title",
                             "Title",
                             "Bibliography title",
                             NULL,
                             G_PARAM_READWRITE);
    properties[PROPERTY_AUTHOR] =
        g_param_spec_string ("author",
                             "Author",
                             "Bibliography author",
                             NULL,
                             G_PARAM_READWRITE);
    properties[PROPERTY_PUBLISHER] =
        g_param_spec_string ("publisher",
                             "Publisher",
                             "Bibliography Publisher",
                             NULL,
                             G_PARAM_READWRITE);
    properties[PROPERTY_YEAR] =
        g_param_spec_uint ("year",
                           "Year",
                           "Bibliography year",
                           0,
                           G_MAXUINT,
                           0,
                           G_PARAM_READWRITE);
    g_object_class_install_properties (base_class, N_PROPERTIES, properties);
}

void
kb_bibtex_printf (KbBibtex *self)
{
    gchar *title, *author, *publisher;
    guint year;

    g_object_get (G_OBJECT (self),
                  "title",     &title,
                  "author",    &author,
                  "publisher", &publisher,
                  "year",      &year,
                  NULL);

    g_printf ("    Title: %s\n"
              "   Author: %s\n"
              "Publisher: %s\n"
              "     Year: %d\n", title, author, publisher, year);

    g_free (title);
    g_free (author);
    g_free (publisher);
}

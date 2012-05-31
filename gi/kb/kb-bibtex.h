#ifndef KB_BIBTEX_H
#define KB_BIBTEX_H

#include <glib-object.h>

#define KB_TYPE_BIBTEX (kb_bibtex_get_type ())
#define KB_BIBTEX(object)                                               \
    G_TYPE_CHECK_INSTANCE_CAST ((object), KB_TYPE_BIBTEX, KbBibtex)
#define KB_IS_BIBTEX(object)                                    \
    G_TYPE_CHECK_INSTANCE_TYPE ((object), KB_TYPE_BIBTEX))
#define KB_BIBTEX_CLASS(klass)                                          \
    (G_TYPE_CHECK_CLASS_CAST ((klass), KB_TYPE_BIBTEX, KbBibtexClass))
#define KB_IS_BIBTEX_CLASS(klass)                               \
    (G_TYPE_CHECK_CLASS_TYPE ((klass), KB_TYPE_BIBTEX))
#define KB_BIBTEX_GET_CLASS(object)                                     \
    (G_TYPE_INSTANCE_GET_CLASS ((object), KB_TYPE_BIBTEX, KbBibtexClass))


typedef struct _KbBibtex KbBibtex;
struct _KbBibtex {
    GObject parent;
};

typedef struct _KbBibtexClass KbBibtexClass;
struct _KbBibtexClass {
    GObjectClass parent_class;
};

GType kb_bibtex_get_type (void);

void kb_bibtex_printf (KbBibtex *self);

#endif

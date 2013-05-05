typedef struct {
    int key;
    const char *value;
} Item;

Item *new_items(size_t len);
const char *search_b(Item *items, size_t len, int key);
const char *search_i(Item *items, size_t len, int key);

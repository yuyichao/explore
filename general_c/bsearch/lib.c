#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "lib.h"

Item*
new_items(size_t len)
{
    Item *items = malloc(sizeof(Item) * len);
    int i;
    for (i = 0;i < len;i++) {
        items[i].key = i;
        items[i].value = "aaa";
    }
    return items;
}

static int
item_compare(const void *_key, const void *_item)
{
    int key = *(int*)_key;
    const Item *item = _item;
    return key - item->key;
}

const char*
search_b(Item *items, size_t len, int key)
{
    Item *item = bsearch(&key, items, len, sizeof(Item), item_compare);
    return item ? item->value : NULL;
}

const char*
search_i(Item *items, size_t len, int key)
{
    Item *item;
    Item *end = items + len;
    for (item = items;item < end;item++) {
        if (item->key == key) {
            return item->value;
        }
    }
    return NULL;
}

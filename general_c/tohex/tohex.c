#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

static inline void
char_to_hex(char c, char res[2])
{
    unsigned char uc = (unsigned char)c;
    res[0] = 'a' + (uc & 0x0f);
    res[1] = 'a' + (uc >> 4);
}

static inline int
check_char(char c)
{
    return c >= 'a' && c < 'a' + 0x10;
}

static inline int
hex_to_char(const char c[2], char *res)
{
    if (!(check_char(c[0]) && check_char(c[1])))
        return 0;
    *res = (c[0] - 'a') + ((c[1] - 'a') << 4);
    return 1;
}

int
main(int argc, char **argv)
{
    if (argc < 2)
        return 1;
#define BUFF_SIZE 1024
    char de_buff[BUFF_SIZE];
    char en_buff[BUFF_SIZE * 2];
    size_t count;
    int i;
    if (strcmp(argv[1], "-e") == 0) {
        while ((count = fread(de_buff, 1, BUFF_SIZE, stdin))) {
            for (i = 0;i < count;i++) {
                char_to_hex(de_buff[i], en_buff + i * 2);
            }
            fwrite(en_buff, 2, count, stdout);
        }
    } else if (strcmp(argv[1], "-d") == 0) {
        while ((count = fread(en_buff, 2, BUFF_SIZE, stdin))) {
            for (i = 0;i < count;i++) {
                if (!hex_to_char(en_buff + i * 2, de_buff + i)) {
                    return 1;
                }
            }
            fwrite(de_buff, 1, count, stdout);
        }
    }
    return 0;
}

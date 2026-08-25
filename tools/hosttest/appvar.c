/* Pull the payload out of a .8xv wrapper; see tools/csx/tifile.py. */

#include "shim.h"

#include <stdlib.h>
#include <string.h>

uint8_t *read_appvar(const char *path, char *name, size_t *size) {
    FILE *file = fopen(path, "rb");
    if (!file)
        return NULL;

    static uint8_t raw[80000];
    size_t total = fread(raw, 1, sizeof raw, file);
    fclose(file);
    if (total < 57 || memcmp(raw, "**TI83F*", 8) != 0)
        return NULL;

    size_t section = (size_t)raw[53] | ((size_t)raw[54] << 8);
    const uint8_t *entry = raw + 55;
    size_t header_len = (size_t)entry[0] | ((size_t)entry[1] << 8);

    memcpy(name, entry + 5, 8);
    name[8] = '\0';
    for (int i = 7; i >= 0 && (name[i] == '\0' || name[i] == ' '); i--)
        name[i] = '\0';

    const uint8_t *var = entry + 2 + header_len + 2;
    size_t payload = (size_t)var[0] | ((size_t)var[1] << 8);
    if (payload + 2 > section)
        return NULL;

    uint8_t *copy = malloc(payload);
    memcpy(copy, var + 2, payload);
    *size = payload;
    return copy;
}

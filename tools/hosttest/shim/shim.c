#include "shim.h"

#include "fileioc.h"
#include "graphx.h"
#include "keypadc.h"

#include <stdlib.h>
#include <string.h>

/* ---------------------------------------------------------------- variables */

#define MAX_VARS 512

typedef struct {
    char name[9];
    uint8_t *data;
    size_t size;
    bool used;
} shim_var_t;

static shim_var_t vars[MAX_VARS];
static uint8_t open_handle_var[16];
static size_t open_handle_pos[16];
static uint8_t next_handle = 1;

void shim_reset_vars(void) {
    for (int i = 0; i < MAX_VARS; i++) {
        free(vars[i].data);
        vars[i].data = NULL;
        vars[i].used = false;
    }
    next_handle = 1;
}

void shim_add_var(const char *name, const void *data, size_t size) {
    for (int i = 0; i < MAX_VARS; i++) {
        if (!vars[i].used) {
            vars[i].used = true;
            snprintf(vars[i].name, sizeof vars[i].name, "%s", name);
            vars[i].data = malloc(size ? size : 1);
            memcpy(vars[i].data, data, size);
            vars[i].size = size;
            return;
        }
    }
    fprintf(stderr, "shim: out of variable slots\n");
    exit(1);
}

const uint8_t *shim_var_data(const char *name, size_t *size) {
    for (int i = 0; i < MAX_VARS; i++) {
        if (vars[i].used && strcmp(vars[i].name, name) == 0) {
            if (size)
                *size = vars[i].size;
            return vars[i].data;
        }
    }
    return NULL;
}

uint8_t ti_Open(const char *name, const char *mode) {
    /* A write mode creates the variable if it is not there, the way fileioc
     * does; the reader relies on that when a chunk arrives. */
    if (mode && (*mode == 'w' || *mode == 'a') && !shim_var_data(name, NULL)) {
        shim_add_var(name, "", 0);
    }

    for (int i = 0; i < MAX_VARS; i++) {
        if (vars[i].used && strcmp(vars[i].name, name) == 0) {
            uint8_t handle = next_handle++;
            if (next_handle >= 16)
                next_handle = 1;
            open_handle_var[handle] = (uint8_t)i;
            open_handle_pos[handle] = 0;
            return handle;
        }
    }
    return 0;
}

int ti_Close(uint8_t handle) { (void)handle; return 1; }

void *ti_GetDataPtr(uint8_t handle) {
    shim_var_t *var = &vars[open_handle_var[handle]];
    return var->data + open_handle_pos[handle];
}

int ti_Delete(const char *name) {
    for (int i = 0; i < MAX_VARS; i++) {
        if (vars[i].used && strcmp(vars[i].name, name) == 0) {
            free(vars[i].data);
            vars[i].data = NULL;
            vars[i].used = false;
            return 1;
        }
    }
    return 0;
}

int ti_Seek(int offset, unsigned origin, uint8_t handle) {
    (void)origin;
    open_handle_pos[handle] = (size_t)offset;
    return 0;
}

size_t ti_Write(const void *data, size_t size, size_t count, uint8_t handle) {
    shim_var_t *var = &vars[open_handle_var[handle]];
    size_t at = open_handle_pos[handle];
    size_t bytes = size * count;

    if (at + bytes > var->size) {
        uint8_t *grown = realloc(var->data, at + bytes);
        if (!grown) return 0;
        var->data = grown;
        var->size = at + bytes;
    }
    memcpy(var->data + at, data, bytes);
    open_handle_pos[handle] = at + bytes;
    return count;
}

int ti_SetArchiveStatus(bool archive, uint8_t handle) {
    (void)archive;
    (void)handle;
    return 1;
}

uint16_t ti_GetSize(uint8_t handle) {
    return (uint16_t)vars[open_handle_var[handle]].size;
}

static uint24_t archive_free_bytes = 2900000;

void shim_set_archive_free(uint24_t bytes) { archive_free_bytes = bytes; }

bool ti_ArchiveHasRoom(uint24_t num_bytes) { return num_bytes <= archive_free_bytes; }

/* ------------------------------------------------------------------ graphics */

uint8_t shim_vbuffer[GFX_LCD_HEIGHT][GFX_LCD_WIDTH];
uint16_t shim_palette[256];
static uint8_t fill_color;

void gfx_FillScreen(uint8_t index) { memset(shim_vbuffer, index, sizeof shim_vbuffer); }

uint8_t gfx_SetColor(uint8_t index) {
    uint8_t previous = fill_color;
    fill_color = index;
    return previous;
}

void gfx_FillRectangle_NoClip(uint24_t x, uint24_t y, uint24_t w, uint24_t h) {
    for (uint24_t row = y; row < y + h && row < GFX_LCD_HEIGHT; row++) {
        for (uint24_t col = x; col < x + w && col < GFX_LCD_WIDTH; col++)
            shim_vbuffer[row][col] = fill_color;
    }
}

uint8_t gfx_SetTextFGColor(uint8_t color) { (void)color; return 0; }
uint8_t gfx_SetTextBGColor(uint8_t color) { (void)color; return 0; }
void gfx_PrintStringXY(const char *s, int x, int y) { (void)s; (void)x; (void)y; }
void gfx_SwapDraw(void) {}
void gfx_Begin(void) {}
void gfx_End(void) {}
void gfx_SetDraw(uint8_t location) { (void)location; }

/* --------------------------------------------------------------- OS display */

void shim_os_clr_home(void) {}
void os_SetCursorPos(uint8_t row, uint8_t col) { (void)row; (void)col; }
uint24_t os_PutStrFull(const char *string) { (void)string; return 0; }

/* ------------------------------------------------------------------- keypad */

#include "keys.h"

#define MAX_FRAMES 8192

uint16_t shim_kb_data[8];
uint8_t shim_kb_config;

static uint16_t script[MAX_FRAMES][8];
static int script_length;
static int script_position;
static long scans;

void shim_keys_clear(void) {
    memset(script, 0, sizeof script);
    script_length = 0;
    script_position = 0;
    scans = 0;
}

void shim_keys_add(kb_lkey_t key, int frames) {
    for (int i = 0; i < frames && script_length < MAX_FRAMES; i++, script_length++) {
        if (key) script[script_length][key >> 8] = (uint8_t)key;
    }
}

long shim_scan_count(void) { return scans; }

void kb_Scan(void) {
    scans++;
    if (script_position < script_length) {
        memcpy(shim_kb_data, script[script_position++], sizeof shim_kb_data);
        return;
    }

    /* Script exhausted: hold nothing down. If the program is still going round
     * its loop long after that, it is not going to exit on its own -- which for
     * most of these tests is exactly what we want to prove. */
    memset(shim_kb_data, 0, sizeof shim_kb_data);
    if (scans - script_length > SHIM_GRACE_SCANS) {
        fflush(stdout);
        exit(SHIM_STILL_RUNNING);
    }
}

/* -------------------------------------------------------------------- ZX0 */

/*
 * In-memory ZX0 decoder, ported from Einar Saukas' dzx0.c in its default
 * (non-"classic") mode -- the same stream the CE toolchain's zx0_Decompress
 * consumes. Being a third independent implementation alongside the Python
 * decoder and the calculator's, it is a genuine cross-check of the encoder.
 */

typedef struct {
    const uint8_t *src;
    int bit_mask;
    int bit_value;
    int backtrack;
    int last_byte;
} zx0_reader_t;

static int zx0_byte(zx0_reader_t *r) {
    return r->last_byte = *r->src++;
}

static int zx0_bit(zx0_reader_t *r) {
    if (r->backtrack) {
        r->backtrack = 0;
        return r->last_byte & 1;
    }
    r->bit_mask >>= 1;
    if (r->bit_mask == 0) {
        r->bit_mask = 128;
        r->bit_value = zx0_byte(r);
    }
    return (r->bit_value & r->bit_mask) ? 1 : 0;
}

static int zx0_gamma(zx0_reader_t *r, int inverted) {
    int value = 1;
    while (!zx0_bit(r))
        value = value << 1 | (zx0_bit(r) ^ inverted);
    return value;
}

void zx0_Decompress(void *dst, const void *src) {
    zx0_reader_t r = { src, 0, 0, 0, 0 };
    uint8_t *out = dst;
    int offset = 1;

    for (;;) {
        for (int n = zx0_gamma(&r, 0); n > 0; n--)
            *out++ = (uint8_t)zx0_byte(&r);

        if (!zx0_bit(&r)) {
            for (int n = zx0_gamma(&r, 0); n > 0; n--, out++)
                *out = *(out - offset);
            if (!zx0_bit(&r))
                continue;
        }

        for (;;) {
            offset = zx0_gamma(&r, 1);
            if (offset == 256)
                return;
            offset = offset * 128 - (zx0_byte(&r) >> 1);
            r.backtrack = 1;
            for (int n = zx0_gamma(&r, 0) + 1; n > 0; n--, out++)
                *out = *(out - offset);
            if (!zx0_bit(&r))
                break;
        }
    }
}

/*
 * The reader's colours.
 *
 * One table, so another theme is one more row. For now there is purple, in
 * Dark -- the default -- and Light, chosen under Settings and kept in the
 * index's device block, so it survives a sync.
 *
 * The same colours reach two screens that store them differently: graphx's
 * palette, 1-5-5-5, for everything in 8bpp, and the LCD's own 5-6-5 with blue
 * in the top bits, for the sync screen, which runs in the operating system's
 * mode.
 */

#ifndef THEME_H
#define THEME_H

#include <stdbool.h>
#include <stdint.h>

typedef struct { uint8_t r, g, b; } rgb_t;

typedef struct {
    const char *name;
    rgb_t bg;           /* the screen */
    rgb_t surface;      /* footers, panels, bars */
    rgb_t fg;           /* text */
    rgb_t dim;          /* secondary text, rules */
    rgb_t accent;       /* headers, highlights, the selection stripe */
    rgb_t on_accent;    /* text on the accent */
    rgb_t select;       /* the selected row */
    rgb_t warn;         /* something the user must act on */
} theme_t;

typedef enum {
    THEME_DARK = 0,     /* what an index with no choice recorded means */
    THEME_LIGHT = 1,
    THEME_COUNT
} theme_id_t;

const theme_t *theme_get(theme_id_t id);

/* The theme the index says, Dark if it says nothing. */
const theme_t *theme_current(void);

uint16_t theme_to_1555(rgb_t colour);
uint16_t theme_to_565(rgb_t colour);

/* `amount` sixteenths of the way from a to b. */
rgb_t theme_mix(rgb_t a, rgb_t b, uint8_t amount);

#endif /* THEME_H */

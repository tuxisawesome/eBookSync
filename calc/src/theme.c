#include "theme.h"

#include "library.h"

/*
 * Purple, dark and light.
 *
 * Dark is a violet-black rather than a neutral one, so the purple reads as the
 * page's own colour and not as a highlight laid on grey. Light is the same
 * accent a shade deeper, which it needs to stay legible on near-white.
 */
static const theme_t THEMES[THEME_COUNT] = {
    [THEME_DARK] = {
        .name = "Dark",
        .bg = { 0x16, 0x12, 0x1f },
        .surface = { 0x24, 0x1d, 0x35 },
        .fg = { 0xec, 0xe8, 0xf6 },
        .dim = { 0x9a, 0x90, 0xb4 },
        .accent = { 0x8b, 0x5c, 0xf6 },
        .on_accent = { 0xff, 0xff, 0xff },
        .select = { 0x3b, 0x2a, 0x6b },
        .warn = { 0xf5, 0x9e, 0x0b },
    },
    [THEME_LIGHT] = {
        .name = "Light",
        .bg = { 0xf8, 0xf6, 0xfc },
        .surface = { 0xec, 0xe6, 0xf8 },
        .fg = { 0x1c, 0x16, 0x28 },
        .dim = { 0x7c, 0x74, 0x92 },
        .accent = { 0x6d, 0x28, 0xd9 },
        .on_accent = { 0xff, 0xff, 0xff },
        .select = { 0xdd, 0xd0, 0xfb },
        .warn = { 0xb4, 0x53, 0x09 },
    },
};

const theme_t *theme_get(theme_id_t id) {
    return &THEMES[id < THEME_COUNT ? id : THEME_DARK];
}

const theme_t *theme_current(void) {
    return theme_get((theme_id_t)lib_theme());
}

uint16_t theme_to_1555(rgb_t c) {
    return (uint16_t)(((c.r >> 3) << 10) | ((c.g >> 3) << 5) | (c.b >> 3));
}

uint16_t theme_to_565(rgb_t c) {
    /* Blue first: the order the LCD and the OS's own colours use in its mode.
     * The other way round, purple comes out green. */
    return (uint16_t)(((c.b >> 3) << 11) | ((c.g >> 2) << 5) | (c.r >> 3));
}

rgb_t theme_mix(rgb_t a, rgb_t b, uint8_t amount) {
    rgb_t out = {
        (uint8_t)((a.r * (16 - amount) + b.r * amount) / 16),
        (uint8_t)((a.g * (16 - amount) + b.g * amount) / 16),
        (uint8_t)((a.b * (16 - amount) + b.b * amount) / 16),
    };
    return out;
}

/*
 * Typing text on a calculator.
 *
 * input.c reports which keys are down; nothing until now turned that into
 * characters, because nothing until now needed any. The password does, so it is
 * worth doing once and properly.
 *
 * The letters are the ones printed on the keys in green, so the calculator
 * itself is the keyboard legend -- there is no on-screen layout to learn and
 * nothing to explain. `alpha` switches between digits and letters and `2nd`
 * switches letter case, which is as close to the OS's own behaviour as is worth
 * getting.
 */

#ifndef KEYIN_H
#define KEYIN_H

#include <stdbool.h>
#include <stdint.h>

/* Comfortably more than a password; the caller bounds it further. */
#define KEYIN_MAX 128

typedef enum {
    KEYIN_TEXT,      /* show what is typed */
    KEYIN_MASKED,    /* show dots -- for the password */
} keyin_style_t;

/*
 * Read a line. Returns false if the user backed out with `clear`.
 *
 * `out` must have room for `max` characters and a terminator. `initial` seeds
 * the buffer, or may be NULL. Drawn on a blank screen with the reader's own
 * chrome, and paced to one LCD frame a turn like every other menu here, so key
 * repeat behaves the same way.
 */
bool keyin_text(const char *prompt, const char *hint, char *out, uint8_t max,
                keyin_style_t style, const char *initial);

#endif /* KEYIN_H */

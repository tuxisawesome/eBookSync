/*
 * Just enough of the CE runtime to compile calc/src on a desktop.
 *
 * The calculator code cannot be emulated here (CEmu needs a calculator ROM
 * dump), but the parts most likely to be wrong -- container parsing, band
 * lookup, and the viewport clipping and 4bpp expansion in render.c -- are pure
 * computation. Compiling them for the host and diffing the frame buffer against
 * the Python decoder catches exactly the bugs that would otherwise only show up
 * on hardware.
 */

#ifndef SHIM_H
#define SHIM_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

/* The eZ80 has native 24-bit integers. 32-bit stands in for them here; every
 * value the reader handles is far below 2^24, so the difference cannot change a
 * result. */
typedef uint32_t uint24_t;
typedef int32_t int24_t;

/*
 * Calls into the operating system made since usb_Init().
 *
 * The reader must not make any while the link is up except from execute(), and
 * the read-only commands must make none at all. That is not a style rule: a
 * binary search over ti_ArchiveHasRoom in the HELLO handler -- twenty-four OS
 * calls, several asking whether eight megabytes would fit -- froze the
 * calculator outright, and no test here could see it because the shim answered
 * instantly. Now they are counted.
 */
unsigned shim_os_calls(void);
void shim_reset_os_calls(void);

/* Register an appvar with the fake fileioc, taking a copy of the payload. */
void shim_add_var(const char *name, const void *data, size_t size);
void shim_reset_vars(void);

/* Look up a variable's current payload, so tests can check what was written. */
const uint8_t *shim_var_data(const char *name, size_t *size);

/*
 * Walk every variable that exists right now.
 *
 * Returns false once `index` runs past the end. Tests use this to dump the
 * whole appvar space after a session, which is the only way to see what a
 * command actually wrote -- a reply says "OK", not what landed in flash.
 */
bool shim_var_at(int index, const char **name, const uint8_t **data, size_t *size);

#endif /* SHIM_H */

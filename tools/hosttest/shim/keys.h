/* Scripted keypresses for the host tests. */

#ifndef SHIM_KEYS_H
#define SHIM_KEYS_H

#include "keypadc.h"

/* Queue `frames` scans with `key` held; key 0 means nothing held. */
void shim_keys_add(kb_lkey_t key, int frames);

/* The same, with several keys held together -- which is how a chord like
 * 2nd+ON is scripted. */
void shim_keys_add_many(const kb_lkey_t *keys, int count, int frames);

void shim_keys_clear(void);

/*
 * ON, which is not in the key matrix.
 *
 * Group 0 of kb_Data is unused by the reader, so the script carries the ON key
 * there and kb_Scan() copies it out into kb_On. That keeps one script format
 * for a keypad that is really two peripherals.
 */
#define kb_KeyOn ((kb_lkey_t)(0 << 8 | 1 << 0))

/* Scans performed so far, so a test can tell a hang from a clean exit. */
long shim_scan_count(void);

/*
 * How many scans to allow once the script runs dry before declaring the program
 * still running. Reaching it exits with SHIM_STILL_RUNNING, which is the
 * *expected* outcome for anything that should not have closed.
 */
#define SHIM_GRACE_SCANS 20000
#define SHIM_STILL_RUNNING 7

#endif /* SHIM_KEYS_H */

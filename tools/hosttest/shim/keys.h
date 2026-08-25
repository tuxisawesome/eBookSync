/* Scripted keypresses for the host tests. */

#ifndef SHIM_KEYS_H
#define SHIM_KEYS_H

#include "keypadc.h"

/* Queue `frames` scans with `key` held; key 0 means nothing held. */
void shim_keys_add(kb_lkey_t key, int frames);
void shim_keys_clear(void);

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

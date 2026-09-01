/*
 * The lock screen.
 *
 * 2nd+ON anywhere in the reader blanks the screen the way the operating
 * system's own power gesture does; ON brings it back to a wallpaper with the
 * date and time across the top and a password prompt under them. Three wrong
 * answers blank it again, still locked, so the calculator is unusable until the
 * password is given.
 *
 * Be clear about what that is and is not. It is a real lock in the sense that
 * there is no way past it from the keypad -- and that cuts both ways: it locks
 * the owner out too. What it cannot be is secure. The batteries can be pulled,
 * and a computer with this page on it can delete the index and be rid of the
 * prompt. That costs the whole table of contents and the wallpaper with it,
 * which is the entire deterrent and is deliberately the same one the password
 * has always had. See docs/FORMAT.md.
 */

#ifndef LOCK_H
#define LOCK_H

#include <stdbool.h>

#include "keyin.h"

/*
 * Lock now: blank the screen, and do not return until the calculator is
 * unlocked again.
 *
 * Restores the palette it found, so the caller can carry on drawing whatever it
 * was drawing. Safe to call before render_init() -- the wallpaper is decoded
 * through one borrowed band buffer rather than the band cache.
 */
void lock_engage(void);

/*
 * Lock if 2nd+ON was pressed on the last input_scan().
 *
 * True if it did, which is the caller's cue to redraw: the screen belongs to
 * the lock while it is up. Every screen that scans the keypad calls this, bar
 * the sync screen -- graphx is shut down there and a transfer is in flight, and
 * locking would strand a strip half-written for the sake of a gesture the user
 * can make a moment later.
 */
bool lock_poll(void);

/*
 * Ask for the password, up to three times. True once it is given.
 *
 * `clear` does not back out: there is nowhere to back out to. Used by
 * lock_engage(), and exposed so the gate on the way into the reader can share
 * the same prompt.
 */
bool lock_prompt(void);

/*
 * What to draw behind that prompt: the wallpaper, with the date and time along
 * the top. Passed to keyin_text() by anything that wants the lock screen's
 * appearance -- including the password gate at startup.
 */
keyin_backdrop_t lock_backdrop(void);

/*
 * Put the operating system's power-on flag in step with the setting.
 *
 * Safe to call at any time, and called on the way into the reader so it
 * re-asserts itself: the flag lives in RAM, so a RAM clear turns it off without
 * telling anybody.
 */
void lock_arm_power_on(void);

/* Is prgmONSCRPT installed? Without it there is nothing for the OS to run. */
bool lock_power_on_ready(void);

#endif /* LOCK_H */

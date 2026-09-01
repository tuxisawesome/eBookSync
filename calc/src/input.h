/* Key edge detection and auto-repeat.
 *
 * keypadc only reports what is held right now, but menus need one step per
 * press and the viewer needs a pan that accelerates while an arrow is held. */

#ifndef INPUT_H
#define INPUT_H

#include <keypadc.h>
#include <stdbool.h>

void input_reset(void);

/* Sample the keypad. Call once per frame. */
void input_scan(void);

bool input_down(kb_lkey_t key);

/* True only on the frame the key goes down. */
bool input_pressed(kb_lkey_t key);

/* True on the initial press, then repeatedly once the key has been held past
 * the initial delay. */
bool input_repeat(kb_lkey_t key);

/* How many frames the current repeat key has been held, for callers that want
 * to accelerate. */
unsigned input_held_frames(void);

/* True while no key at all is down. */
bool input_idle(void);

/*
 * ON, which kb_Scan() cannot see.
 *
 * It sits on a different peripheral from the key matrix, so it is sampled
 * separately inside input_scan() and reported here. Everything above this file
 * can then go on treating the keypad as one thing.
 */
bool input_on_down(void);
bool input_on_pressed(void);

/*
 * 2nd: lock the calculator.
 *
 * It was 2nd+ON, to echo the operating system'"'"'s own power gesture. That did not
 * work: ON is not in the key matrix, and reading it needs a latch this never
 * enabled, so the chord could never fire. 2nd on its own is what the key is
 * free for now that the sync screen has moved under Settings -- and a key that
 * works beats a key that reads well.
 *
 * Screens where 2nd already means something -- the password prompt, where it
 * switches case, and the yes/no screens, where it is yes -- do not ask.
 */
bool input_lock_combo(void);

/*
 * Block until ON is pressed, and only ON.
 *
 * What the lock screen wakes on. It does not scan the key matrix at all --
 * kb_Scan() disables interrupts and waits on a hardware scan, roughly a
 * millisecond, and doing that in a loop is the opposite of asleep. The ON latch
 * holds the press until it is read, so nothing is missed between polls.
 */
void input_wait_for_on(void);

/* Hand the ON latch back. It persists between programs, so this must run on
 * every way out of the reader. */
void input_release(void);

#endif /* INPUT_H */

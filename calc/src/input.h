/* Key edge detection and auto-repeat.
 *
 * keypadc only reports what is held right now, but menus need one step per
 * press and the viewer needs a pan that accelerates while an arrow is held. */

#ifndef INPUT_H
#define INPUT_H

#include <keypadc.h>
#include <stdbool.h>

void input_reset(void);

/*
 * Switch the keypad to scanning itself, and back.
 *
 * kb_Scan() disables interrupts while it runs. That is harmless in a menu that
 * scans once per frame, and fatal in the sync loop, which spins as fast as it
 * can right next to an interrupt-driven USB driver: the driver never gets its
 * interrupts, transfers never complete, and the keypad looks dead into the
 * bargain. In continuous mode the keypad controller scans on its own and
 * input_scan() just reads the result, touching no interrupts at all.
 */
void input_begin_continuous(void);
void input_end_continuous(void);

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

#endif /* INPUT_H */

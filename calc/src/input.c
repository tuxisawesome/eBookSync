#include "input.h"

#include <string.h>

/*
 * Frames before a held key starts repeating, and frames between repeats.
 *
 * These are real LCD frames now -- see ui_present -- so 18 is about 300ms
 * before the first repeat and 4 is a little over a dozen steps a second. They
 * used to be counted in loop iterations of no fixed length, which is why the
 * cursor shot off the end of the list at the slightest touch.
 */
#define REPEAT_DELAY  18
#define REPEAT_RATE   4

static uint8_t current[8];
static uint8_t previous[8];
static kb_lkey_t repeat_key;
static unsigned repeat_frames;

/*
 * ON, which is not in the key matrix and never will be.
 *
 * kb_Data is one peripheral at 0xF50010 and the ON key is another at 0xF00020,
 * so kb_Scan() cannot see it however often it runs. It gets its own pair of
 * bits here so that everything above this file can go on treating the keypad as
 * one thing.
 *
 * Read through keypadc's ON latch, which has to be enabled explicitly -- and
 * not enabling it is why the first version of this never saw the key at all.
 * The latch also means a press is caught however briefly it is held, which
 * matters for waking: the calculator is asleep between scans, and a level read
 * would miss a press that happened in the gap.
 *
 * The header warns the latch persists between programs, so input_reset() turns
 * it on and input_release() turns it off again on the way out.
 */
static bool on_current;
static bool on_previous;

void input_reset(void) {
    /*
     * Seed both snapshots from what is held right now rather than zeroing them.
     * The program is launched by pressing enter, and that key is still down when
     * main() starts -- zeroing would make the next scan look like a fresh press
     * and open whatever the menu happened to be pointing at.
     */
    kb_Scan();
    for (uint8_t group = 1; group < 8; group++)
        current[group] = (uint8_t)kb_Data[group];
    memcpy(previous, current, sizeof previous);

    kb_EnableOnLatch();
    kb_ClearOnLatch();
    on_current = on_previous = kb_On != 0;

    repeat_key = 0;
    repeat_frames = 0;
}

void input_scan(void) {
    memcpy(previous, current, sizeof previous);
    kb_Scan();
    for (uint8_t group = 1; group < 8; group++)
        current[group] = (uint8_t)kb_Data[group];

    on_previous = on_current;
    on_current = kb_On != 0;
}

bool input_on_down(void) {
    return on_current;
}

bool input_on_pressed(void) {
    return on_current && !on_previous;
}

bool input_lock_combo(void) {
    return input_pressed(kb_Key2nd);
}

bool input_down(kb_lkey_t key) {
    return (current[key >> 8] & (uint8_t)key) != 0;
}

bool input_pressed(kb_lkey_t key) {
    uint8_t mask = (uint8_t)key;
    return (current[key >> 8] & mask) && !(previous[key >> 8] & mask);
}

bool input_repeat(kb_lkey_t key) {
    if (!input_down(key)) {
        if (repeat_key == key) {
            repeat_key = 0;
            repeat_frames = 0;
        }
        return false;
    }

    if (repeat_key != key) {
        repeat_key = key;
        repeat_frames = 0;
        return true;
    }

    repeat_frames++;
    if (repeat_frames < REPEAT_DELAY)
        return false;
    return ((repeat_frames - REPEAT_DELAY) % REPEAT_RATE) == 0;
}

unsigned input_held_frames(void) {
    return repeat_frames;
}

bool input_idle(void) {
    for (uint8_t group = 1; group < 8; group++) {
        if (current[group])
            return false;
    }
    return true;
}

void input_wait_for_on(void) {
    /* Start from nothing latched, so a press from before the wait does not end
     * it the moment it begins. */
    kb_ClearOnLatch();
    while (!(kb_On))
        ;
    kb_ClearOnLatch();
}

void input_release(void) {
    kb_DisableOnLatch();
}

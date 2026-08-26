#include "input.h"

#include <string.h>

/* Frames before a held key starts repeating, and the gap between repeats. */
#define REPEAT_DELAY  14
#define REPEAT_RATE   2

static uint8_t current[8];
static uint8_t previous[8];
static kb_lkey_t repeat_key;
static unsigned repeat_frames;
static bool continuous;

void input_reset(void) {
    /*
     * Seed both snapshots from what is held right now rather than zeroing them.
     * The program is launched by pressing enter, and that key is still down when
     * main() starts -- zeroing would make the next scan look like a fresh press
     * and open whatever the menu happened to be pointing at.
     */
    if (!continuous)
        kb_Scan();
    for (uint8_t group = 1; group < 8; group++)
        current[group] = (uint8_t)kb_Data[group];
    memcpy(previous, current, sizeof previous);

    repeat_key = 0;
    repeat_frames = 0;
}

void input_begin_continuous(void) {
    kb_SetMode(MODE_3_CONTINUOUS);
    continuous = true;
}

void input_end_continuous(void) {
    continuous = false;
    kb_SetMode(MODE_0_IDLE);
}

void input_scan(void) {
    memcpy(previous, current, sizeof previous);
    /* In continuous mode the controller has already done the scanning, and
     * calling kb_Scan() here would disable interrupts for no reason. */
    if (!continuous)
        kb_Scan();
    for (uint8_t group = 1; group < 8; group++)
        current[group] = (uint8_t)kb_Data[group];
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

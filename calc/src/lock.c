#include "lock.h"

#include "input.h"
#include "keyin.h"
#include "library.h"
#include "render.h"
#include "ui.h"
#include "wall.h"

#include <graphx.h>
#include <stdio.h>
#include <sys/lcd.h>
#include <sys/power.h>
#include <sys/rtc.h>
#include <tice.h>

/* Three, the same as the gate on the way in. */
#define LOCK_TRIES  3

/* Black, for the blanked screen. Artwork owns 0-15 and the chrome 240-252. */
#define LOCK_BLACK  253

#define BAR_HEIGHT  18

/* ------------------------------------------------------------------ clock */

/*
 * The calculator's own clock, not lib_now().
 *
 * lib_now() is unix seconds corrected by an offset the sync page sends, which
 * is the right thing for a read timestamp and the wrong thing here: it is UTC,
 * and a clock on a lock screen is a wall clock. boot_GetTime() reads the RTC
 * the owner set in the operating system's own clock settings, which is already
 * local time and needs nothing from anybody. If it is wrong, it is wrong in a
 * place the owner can see and fix.
 */
static const char *const MONTHS[] = {
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
};

static const char *const DAYS[] = {
    "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
};

/* Sakamoto's method: day of the week from a civil date, no tables and no
 * arithmetic wider than the eZ80 wants. */
static uint8_t weekday(uint8_t day, uint8_t month, uint16_t year) {
    static const uint8_t shift[] = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 };
    if (month < 3)
        year--;
    return (uint8_t)((year + year / 4 - year / 100 + year / 400
                      + shift[month - 1] + day) % 7);
}

static void draw_bar(void) {
    uint8_t day, hours, minutes, seconds;
    uint8_t month;
    uint16_t year;

    boot_GetDate(&day, &month, &year);
    boot_GetTime(&seconds, &minutes, &hours);

    gfx_SetColor(UI_BG);
    gfx_FillRectangle_NoClip(0, 0, GFX_LCD_WIDTH, BAR_HEIGHT);
    gfx_SetTextFGColor(UI_FG);
    gfx_SetTextBGColor(UI_BG);

    char line[32];
    if (month >= 1 && month <= 12) {
        sprintf(line, "%s %u %s %u", DAYS[weekday(day, month, year)], day,
                MONTHS[month - 1], year);
    } else {
        /* An unset clock rather than a broken one. Say so instead of printing
         * something that looks like a date and is not. */
        sprintf(line, "Clock not set");
    }
    gfx_PrintStringXY(line, 6, 5);

    sprintf(line, "%02u:%02u", hours, minutes);
    gfx_PrintStringXY(line, GFX_LCD_WIDTH - 6 - 5 * 8, 5);
}

/* --------------------------------------------------------------- backdrop */

static void backdrop(void) {
    if (!wall_draw())
        gfx_FillScreen(UI_BG);

    /* wall_draw() loaded the wallpaper's colours into 0-15; the bar and the
     * prompt are drawn in the chrome entries above them, which it did not
     * touch. */
    draw_bar();
}

keyin_backdrop_t lock_backdrop(void) {
    return backdrop;
}

/* ------------------------------------------------------------------ sleep */

/*
 * Off, as far as anyone holding it is concerned.
 *
 * Not boot_TurnOff(): the toolchain's own header says it "is likely to leak
 * memory", and it would end this program -- which is the one thing that must
 * not happen, because the program is the lock. A calculator that came back to
 * the operating system's homescreen would be unlocked.
 *
 * So the screen goes black, the backlight goes out and the CPU drops to 6 MHz
 * until ON is pressed. From the outside that is 2nd+ON; the difference is that
 * this one is still holding the door shut.
 */
static void sleep_until_on(void) {
    uint8_t backlight = lcd_BacklightLevel;

    gfx_palette[LOCK_BLACK] = 0;
    gfx_FillScreen(LOCK_BLACK);
    gfx_SwapDraw();
    gfx_Wait();
    gfx_FillScreen(LOCK_BLACK);

    lcd_BacklightLevel = 255;   /* 0 is brightest, 255 darkest */
    boot_Set6MHzMode();

    /*
     * Let go, press, let go. Scanning rather than spinning on the ON line: the
     * scan is what a scripted test advances on, and on hardware it costs
     * nothing that matters while the calculator is doing precisely nothing
     * else.
     */
    do { input_scan(); } while (input_on_down());
    do { input_scan(); } while (!input_on_down());
    do { input_scan(); } while (input_on_down());

    boot_Set48MHzMode();
    lcd_BacklightLevel = backlight;
    input_reset();
}

/* ------------------------------------------------------------------- lock */

/*
 * Wait for any key, over the wallpaper. There is nothing to ask for.
 *
 * Redrawn only to move the clock on. Painting the wallpaper every frame would
 * mean eight decompressions and a full-screen blit sixty times a second to show
 * a picture that is not changing, which is a strange thing for a screen whose
 * whole purpose is to be idle.
 */
static void wait_for_any_key(void) {
    unsigned since_redraw = 0;
    bool dirty = true;

    /* Whatever woke it is still held down; that must not also dismiss it. */
    do { input_scan(); } while (!input_idle());

    for (;;) {
        if (dirty) {
            backdrop();
            ui_present(true);
            dirty = false;
            since_redraw = 0;
        } else {
            ui_present(false);
        }

        input_scan();
        if (!input_idle())
            return;

        if (++since_redraw >= 60)
            dirty = true;
    }
}

void lock_engage(void) {
    /* The wallpaper takes palette entries 0-15, which belong to whatever was
     * on screen -- a strip in the viewer, or nothing in particular in a menu.
     * Give them back on the way out so the caller can just carry on. */
    uint16_t saved[CSX_PALETTE_SIZE];
    for (uint8_t i = 0; i < CSX_PALETTE_SIZE; i++)
        saved[i] = gfx_palette[i];

    for (;;) {
        sleep_until_on();

        if (!lib_password_set()) {
            /* Nothing to ask. It is still a useful gesture -- the screen goes
             * off and comes back -- so it stays a gesture rather than becoming
             * an error message. */
            wait_for_any_key();
            break;
        }

        if (lock_prompt())
            break;

        /* Out of tries. Back to sleep, still locked: there is no way past this
         * from the keypad, which is the point and also the cost. */
    }

    for (uint8_t i = 0; i < CSX_PALETTE_SIZE; i++)
        gfx_palette[i] = saved[i];
    input_reset();
}

/*
 * Ask for the password, up to three times.
 *
 * `clear` does not back out of this one. There is nowhere to back out to: the
 * screen behind it is the library this is keeping shut.
 */
bool lock_prompt(void) {
    for (uint8_t tries = LOCK_TRIES; tries; tries--) {
        char hint[40];
        if (tries == LOCK_TRIES)
            hint[0] = '\0';
        else
            sprintf(hint, "%u attempt(s) left.", tries);

        char entered[LIB_PASSWORD_MAX + 1];
        if (!keyin_text("Locked", hint[0] ? hint : NULL, entered,
                        LIB_PASSWORD_MAX, KEYIN_MASKED, NULL, backdrop)) {
            /* clear: no way out, so treat it as a wrong answer and redraw. */
            continue;
        }

        if (lib_password_check(entered)) {
            uint8_t failures = lib_password_failures();
            lib_password_clear_failures();

            if (failures) {
                char line[40];
                sprintf(line, "%u failed attempt(s) since", failures);
                ui_message(line, "you last unlocked this.");
            }
            return true;
        }

        lib_password_note_failure();
        ui_message("Wrong password.",
                   tries > 1 ? "Try again." : "Turning off.");
    }
    return false;
}

/*
 * The lock draws its own screens, and those screens scan the keypad through the
 * same helpers everything else does -- so without this, holding the combination
 * down while the prompt is up would lock on top of the lock.
 */
static bool locking;

bool lock_poll(void) {
    if (locking || !input_lock_combo())
        return false;

    locking = true;
    lock_engage();
    locking = false;
    return true;
}

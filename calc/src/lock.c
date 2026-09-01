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
#include <fileioc.h>
#include <ti/flags.h>
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

/*
 * The wake screen: the wallpaper, with the date and time across the top.
 *
 * Not the backdrop to the password prompt. Drawing a full-screen image behind
 * every keystroke means eight decompressions and a full-screen blit per
 * character, on a calculator, to show a picture nobody is looking at while they
 * are typing. So the wallpaper is what you wake to, and the prompt that follows
 * it is drawn on a plain background.
 */
static void draw_wake_screen(void) {
    if (!wall_draw())
        gfx_FillScreen(UI_BG);

    /* wall_draw() loaded the wallpaper's colours into 0-15; the bar is drawn in
     * the chrome entries above them, which it did not touch. */
    draw_bar();
}

/*
 * Show it until any key is pressed.
 *
 * Redrawn only to move the clock on -- see draw_wake_screen(). Whatever woke
 * the calculator is still held down when this starts, and must not also
 * dismiss it.
 */
void lock_wake_screen(void) {
    unsigned since_redraw = 0;
    bool dirty = true;

    do { input_scan(); } while (!input_idle());

    for (;;) {
        if (dirty) {
            draw_wake_screen();
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

/* ------------------------------------------------------------------ sleep */

/*
 * Ask the operating system to turn the calculator off, now.
 *
 * Not boot_TurnOff(): the toolchain's own header says it "is likely to leak
 * memory", and it would end this program -- which is the one thing that must
 * not happen, because the program is the lock. A calculator that came back to
 * the homescreen would be unlocked.
 *
 * Instead, wind the automatic power-down timer to nothing and let the OS do
 * what it already knows how to do. It is a suspend, not a kill: the OS puts the
 * calculator to sleep and resumes this program where it left off when ON is
 * pressed, which is exactly the behaviour a lock needs. Cesium's power-on
 * password does the same thing, and it is the calculator's own 2nd+ON path, so
 * the power-off is real rather than an imitation of one.
 */
static void power_down(void) {
    os_EnableAPD();
    os_ApdSubTimer = 1;
    os_ApdTimer = 1;
    os_Flags[OS_FLAGS_APD] |= 1 << OS_FLAGS_APD_RUNNING;
}

/*
 * Off, and not back until ON.
 *
 * The screen is blacked before the power-down is armed rather than after, so
 * there is no moment where the library is readable on a calculator that has
 * been told to go to sleep.
 *
 * The wait afterwards is not redundant. If the power-down fires, this is what
 * resumes when the OS wakes the program; if it does not -- and whether APD
 * fires from inside a program with graphx holding the LCD is the one thing here
 * that only hardware can answer -- this is the whole of the behaviour, a dark
 * screen at 6 MHz until ON. Either way the calculator is dark and locked, and
 * the difference is battery rather than correctness.
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
    power_down();

    /*
     * ON, and only ON. Scanning the key matrix would mean kb_Scan() in a tight
     * loop -- interrupts off and a hardware scan every time round -- which is
     * not what a calculator that is supposed to be off should be doing. The ON
     * latch holds the press until it is read, so nothing is missed while this
     * waits.
     */
    input_wait_for_on();

    /*
     * Take the timer back before the prompt goes up. It was wound to nothing to
     * force the power-down, and leaving it there would turn the calculator off
     * again in the middle of somebody typing their password.
     */
    os_DisableAPD();

    boot_Set48MHzMode();

    /*
     * A wake from the power-down hands the LCD back in the operating system's
     * own 16bpp mode, and graphx will not put it back if it believes it is
     * already running -- which shows up as the last thing drawn repeating four
     * times in the wrong colours, 8bpp bytes being read two to a pixel. End it
     * first so the re-init actually re-initialises. Harmless if the power-down
     * never fired.
     */
    gfx_End();
    gfx_Begin();
    gfx_SetDrawBuffer();
    ui_set_chrome_palette();

    lcd_BacklightLevel = backlight;
    input_reset();
}

/* ------------------------------------------------------------------- lock */

void lock_engage(void) {
    /* The wallpaper takes palette entries 0-15, which belong to whatever was
     * on screen -- a strip in the viewer, or nothing in particular in a menu.
     * Give them back on the way out so the caller can just carry on. */
    uint16_t saved[CSX_PALETTE_SIZE];
    for (uint8_t i = 0; i < CSX_PALETTE_SIZE; i++)
        saved[i] = gfx_palette[i];

    for (;;) {
        sleep_until_on();

        /*
         * The wallpaper first, then the prompt. With no password set there is
         * nothing to ask, and the gesture is simply a screen blanker -- so the
         * wake screen is the whole of it.
         */
        lock_wake_screen();

        if (!lib_password_set())
            break;

        if (lock_prompt())
            break;

        /* Out of tries. Back to sleep, still locked: there is no way past this
         * from the keypad, which is the point and also the cost. */
    }

    /* sleep_until_on() took the automatic power-down away so it could not fire
     * mid-password. Give it back: it is the calculator's normal behaviour and
     * not ours to switch off. */
    os_EnableAPD();

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
                        LIB_PASSWORD_MAX, KEYIN_MASKED, NULL, NULL)) {
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
        if (tries > 1)
            lock_wake_screen();
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

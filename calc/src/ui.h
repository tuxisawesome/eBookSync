#ifndef UI_H
#define UI_H

#include <stdbool.h>
#include <stdint.h>

#define UI_ROW_HEIGHT  20
#define UI_LIST_TOP    22
#define UI_LIST_ROWS   10

/* Load the reader's own colours into the palette entries above the artwork.
 * Call after any change to the strip palette. */
void ui_set_chrome_palette(void);

/*
 * Show what has been drawn and wait for the frame.
 *
 * Menus used to run flat out, so key repeat was counted in loop iterations of
 * unknown length and the cursor shot across the list. This paces every turn to
 * one LCD frame, which makes the repeat rate mean something in seconds.
 *
 * `drew` copies the new frame back into the drawing buffer so both hold the
 * same image; without that, pacing by swapping every turn would flicker between
 * the current frame and the previous one.
 */
void ui_present(bool drew);

void ui_header(const char *text);
void ui_footer(const char *text);

/* Blit a pre-rendered 2bpp title through the normal or selected ramp. */
void ui_draw_title(uint16_t title_offset, int x, int y, bool selected);

/* Centred one-line message on a blank screen, shown until a key is pressed. */
void ui_message(const char *line1, const char *line2);

/*
 * The same, but drawn and returned from at once.
 *
 * For saying what is happening before something slow starts -- a screen that
 * waits for a key cannot do that, and a calculator that looks dead for several
 * seconds gets its battery pulled.
 */
void ui_notice(const char *line1, const char *line2);

/* What a menu loop returned. */
typedef enum {
    UI_CHOSE,     /* the user picked the highlighted row */
    UI_BACK,      /* the user backed out */
    UI_SYNC,      /* the user asked for the sync screen */
    UI_SETUP,     /* the user asked for the settings screen */
    UI_CHAT,      /* the user asked for the chat screen */
} ui_result_t;

/* Settings: what is stored, resetting the library, and about. */
void ui_setup_screen(void);

/*
 * Ask for the password on the way in. True to let the user through.
 *
 * Three wrong answers and the reader quits. That is a speed bump rather than a
 * lock -- relaunching gives three more -- so the count of failed attempts is
 * kept in the index and shown to whoever does get in. See lib_password_check().
 */
#define UI_PASSWORD_TRIES 3
bool ui_password_gate(void);

/*
 * Messages. Nothing here touches the link -- what is read arrived at the last
 * sync, and what is typed leaves at the next one.
 */
void ui_chat_screen(void);

/* The text of about.txt, baked in at build time and scrollable. */
void ui_about_screen(void);

/* Yes/no, drawn over a blank screen. Returns true for yes. */
bool ui_confirm(const char *line1, const char *line2);

/* The same screen, but running a bare echo instead of the protocol. */
void ui_sync_run(bool echo_only);

ui_result_t ui_book_menu(uint16_t *selection);
ui_result_t ui_strip_menu(uint16_t book_index, uint16_t *selection);

#endif /* UI_H */

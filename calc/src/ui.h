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

void ui_header(const char *text);
void ui_footer(const char *text);

/* Blit a pre-rendered 2bpp title through the normal or selected ramp. */
void ui_draw_title(uint16_t title_offset, int x, int y, bool selected);

/* Centred one-line message on a blank screen, shown until a key is pressed. */
void ui_message(const char *line1, const char *line2);

/* What a menu loop returned. */
typedef enum {
    UI_CHOSE,     /* the user picked the highlighted row */
    UI_BACK,      /* the user backed out */
    UI_SYNC,      /* the user asked for the sync screen */
    UI_ECHO,      /* the user asked for the link echo test */
} ui_result_t;

/* Take over USB and serve the sync protocol until the computer disconnects or
 * the user presses clear. */
void ui_sync_screen(void);

/* The same screen, but running a bare echo instead of the protocol. */
void ui_sync_run(bool echo_only);

ui_result_t ui_book_menu(uint16_t *selection);
ui_result_t ui_strip_menu(uint16_t book_index, uint16_t *selection);

#endif /* UI_H */

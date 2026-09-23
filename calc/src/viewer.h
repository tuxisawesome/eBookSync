#ifndef VIEWER_H
#define VIEWER_H

#include <stdbool.h>
#include <stdint.h>

/* How reading a strip ended. */
typedef enum {
    VIEW_BACK,      /* clear: back to whichever list opened it */
    VIEW_NEXT,      /* pressed on past the end: open the next strip of the book */
    VIEW_FAILED,    /* the strip would not open; the user has been told why */
} view_result_t;

/*
 * Read one strip. Handles panning, paging, zooming, marking read, bookmarking,
 * and saving the scroll position back to the index.
 *
 * A strip made from several images is read one image at a time: scrolling
 * stops at the bottom of each, and a fresh press of down goes on to the next.
 * At the bottom of the last one the same press goes on to the next strip of
 * the book, which is what VIEW_NEXT asks the caller to open.
 */
view_result_t viewer_run(uint16_t strip_index);

#endif /* VIEWER_H */

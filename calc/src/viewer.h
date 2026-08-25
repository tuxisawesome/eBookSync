#ifndef VIEWER_H
#define VIEWER_H

#include <stdbool.h>
#include <stdint.h>

/* Read one strip. Handles panning, zooming, marking read and saving the scroll
 * position back to the index. Returns false if the strip could not be opened,
 * having already told the user why. */
bool viewer_run(uint16_t strip_index);

#endif /* VIEWER_H */

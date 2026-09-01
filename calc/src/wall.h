/*
 * The lock screen wallpaper.
 *
 * It is an ordinary .csx container in a reserved slot -- a 320x240 image is
 * just a very short strip -- so it needs no format of its own, no transfer
 * command of its own, and no decoder of its own. It arrives through PUT_CHUNK
 * like a comic and is checksummed on the way in like a comic.
 *
 * What is not ordinary is that it is tied to the index. `CSFFFF00` would
 * otherwise outlive `CSLIB`, and deleting the index is the one way past the
 * password -- so a calculator whose table of contents had been thrown away
 * would still come up with the owner's wallpaper on it, looking for all the
 * world like it belonged to whoever was holding it. The claim lives in the
 * device block instead: no index means no claim, which means no wallpaper and
 * the appvars swept on the next run. See docs/FORMAT.md.
 */

#ifndef WALL_H
#define WALL_H

#include <stdbool.h>
#include <stdint.h>

/* Is there a wallpaper the index vouches for? Cheap after the first call. */
bool wall_present(void);

/*
 * Draw it over the whole screen, in the current draw buffer.
 *
 * Loads the wallpaper's own colours into palette entries 0-15, so the caller
 * must put back whatever was there -- ui_set_chrome_palette() for the menus, or
 * the strip's own palette when returning to the viewer.
 *
 * False if there is no usable wallpaper, in which case nothing was drawn and
 * the palette is untouched.
 */
bool wall_draw(void);

/*
 * Record the wallpaper that has just been stored in the reserved slot.
 *
 * Checksums it where it lies in flash and writes the claim into the device
 * block. False if the slot holds nothing openable, in which case the claim is
 * cleared rather than left pointing at wreckage.
 */
bool wall_adopt(void);

/* Delete the wallpaper and its claim. */
void wall_forget(void);

/*
 * Delete a wallpaper the index does not vouch for.
 *
 * Called once at startup. This is what makes deleting `CSLIB` cost the
 * wallpaper as well as the table of contents.
 */
void wall_sweep(void);

#endif /* WALL_H */

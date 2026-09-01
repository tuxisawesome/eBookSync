/*
 * CSLIB: the index of what is actually on the calculator.
 *
 * Parsed in place from flash rather than copied into RAM -- the band cache
 * needs every byte it can get. Only the 17-byte strip record is ever written
 * back, and only when the reader leaves a strip.
 *
 * Titles are ZX0-compressed 2bpp bitmaps rendered by the sync app, because the
 * calculator has no CJK font. See docs/FORMAT.md.
 */

#ifndef LIBRARY_H
#define LIBRARY_H

#include <stdbool.h>
#include <stdint.h>

#define LIB_NAME        "CSLIB"
#define LIB_MAGIC       "CSLIB"
#define LIB_VERSION     3

/* What the eBookSync naming called the same two things, swept once on first run. */
#define LIB_LEGACY_NAME "EOSLIB"

/* Identifies which library on the computer these comics came from. */
#define LIB_ID_SIZE     16
#define LIB_FLAG_READ   0x01

/*
 * The largest slot a strip can be given.
 *
 * A slot names the appvars a strip lives in, and an appvar name is eight
 * characters: "CS" plus four hex digits of slot plus two of chunk. So the
 * naming is what caps this, and this spends all of it. It used to be one byte,
 * which capped a *library* -- not a calculator -- at 256 strips, because a slot
 * is assigned once and kept even for strips that are not resident.
 *
 * One short of 0xFFFF, which belongs to the lock screen wallpaper. See
 * CSX_WALLPAPER_SLOT.
 */
#define LIB_MAX_SLOT    0xFFFE

/* Largest 2bpp title bitmap the reader has to expand, in bytes. */
#define LIB_TITLE_MAX   1200

typedef struct {
    uint16_t slot;
    uint8_t chunk_count;
    uint24_t bytes;
    uint8_t flags;
    uint32_t read_at;
    uint24_t pos;         /* saved scroll position, in the saved layer's rows */
    uint8_t layer;        /* zoom layer last used */
    uint16_t title;       /* offset of the title record within the index */
} lib_strip_t;

typedef struct {
    uint16_t title;
    uint16_t strip_first;
    uint16_t strip_count;
} lib_book_t;

/*
 * The last 64 bytes of the header belong to the calculator rather than to the
 * computer: the password, and settings the computer has no business knowing.
 *
 * It lives here, and not in an appvar of its own, so that deleting it to get
 * past the password also destroys the table of contents -- book grouping, the
 * title bitmaps, the slot to strip mapping, read state and chunk counts. What
 * would be left is megabytes of EO** appvars with no way to tell what any of
 * them is. That is the whole deterrent: the bypass costs the library until you
 * are back at the computer that can rebuild it.
 *
 * The computer replaces this variable on every index push, so INDEX_PUT splices
 * the old block over the incoming bytes and INDEX_GET zeroes it in the reply.
 */
#define LIB_HEADER_SIZE   92
#define LIB_DEVICE_OFFSET 28
#define LIB_DEVICE_SIZE   64

/* Map the index. False when there is no library on the calculator yet. */
bool lib_open(void);

/*
 * The device block, or NULL if there is no index. Points into flash.
 *
 * lib_set_device() rewrites it in place, which unarchives and re-archives the
 * index, so every cached pointer into it moves; it re-maps before returning.
 */
const uint8_t *lib_device(void);
bool lib_set_device(const uint8_t *block);

/*
 * Unix seconds, which is not what the calculator's clock gives you.
 *
 * The CE has an RTC, but time() counts from an epoch this code has no business
 * assuming and the clock is very often simply unset. So the computer sends the
 * real time at the start of every sync and the difference is kept in the device
 * block; lib_now() adds it back. Nothing here depends on the RTC being right,
 * only on it running.
 *
 * lib_set_clock() writes only when the correction has moved by more than a
 * minute -- a write is an unarchive and re-archive of the index, and drift of a
 * few seconds is not worth one on every sync.
 */
uint32_t lib_now(void);
bool lib_set_clock(uint32_t unix_seconds);

/*
 * The password, which lives in the device block for the reason above.
 *
 * Stored as a random 16-byte salt and SHA-256(salt || password), so the
 * password itself is not on the calculator and the same password on two
 * calculators does not produce the same bytes.
 *
 * Be clear about what this is: a deterrent, not security. Anyone with a cable
 * and the sync page can already read what is stored, and anyone willing to lose
 * the library can delete the index. What it buys is that a bypass costs the
 * whole table of contents until the owner is back at the computer that can
 * rebuild it.
 */
#define LIB_PASSWORD_MAX 32

bool lib_password_set(void);
bool lib_password_check(const char *password);

/* Set or, with NULL, remove. Creates an index if there is not one yet. */
bool lib_password_store(const char *password);

/*
 * Failed attempts since the last successful unlock.
 *
 * Kept across power cycles, and not as a rate limit -- pulling the batteries
 * would defeat that, and locking the owner out permanently would cost them the
 * library. It is tamper evidence: the number is shown to whoever does get in,
 * so an attempt to guess it does not go unnoticed.
 */
uint8_t lib_password_failures(void);
bool lib_password_note_failure(void);
bool lib_password_clear_failures(void);

/*
 * The lock screen wallpaper's checksum, if the index claims one.
 *
 * It lives in the device block for the same reason the password does: deleting
 * the index to get past the prompt has to cost something. Without the claim the
 * wallpaper appvars are so many unreadable bytes, and the reader deletes them.
 *
 * lib_set_wallpaper(NULL) clears the claim.
 */
bool lib_wallpaper(uint32_t *crc);
bool lib_set_wallpaper(const uint32_t *crc);

/*
 * Make sure an index exists, creating an empty one if it does not.
 *
 * Setting a password before the first sync has to have somewhere to put it, and
 * an index with no books in it is a perfectly ordinary thing for a calculator
 * that has never synced.
 */
bool lib_ensure(void);

/*
 * Delete anything eBookSync left behind, returning how many appvars went.
 *
 * The eOS naming renamed every variable this owns, so a calculator that ran it
 * is holding a library this can no longer read and will never write to again --
 * typically megabytes of it. Nothing else ever cleans that up.
 */
uint16_t lib_sweep_legacy(void);

/* Is there a library here under the eOS names, which this cannot read? */
bool lib_has_legacy(void);

/*
 * The library's identifier, or NULL if there is no library.
 *
 * The computer generates one per library folder and sends it with every
 * connection. If it does not match, these comics came from somewhere else and
 * mixing the two would leave a library the computer cannot account for.
 *
 * An all-zero id means no identity rather than an identity of zero -- that is
 * what an emptied index carries, and what the page sends when no library folder
 * has been chosen. Both must read as "empty", not as "someone else's".
 */
const uint8_t *lib_id(void);

/* Mark every strip of a book read or unread, in one rewrite of the index. */
bool lib_set_book_read(const lib_book_t *book, bool read);

/*
 * Delete every strip, and empty the index without deleting it.
 *
 * The index is not deleted because the device block is in it: erasing the
 * library must not clear the password as a side effect. What is left is a valid
 * index with no books, no strips and no library id, so the next computer to
 * connect is told the calculator is empty rather than holding someone else's.
 *
 * Returns strips removed.
 */
uint16_t lib_reset(void);

uint16_t lib_book_count(void);
uint16_t lib_strip_count(void);

void lib_get_book(uint16_t index, lib_book_t *book);
void lib_get_strip(uint16_t index, lib_strip_t *strip);

/* How many strips of a book are marked read. */
uint16_t lib_book_read_count(const lib_book_t *book);

/*
 * Persist one strip's read flag, scroll position and zoom layer.
 *
 * This rewrites the index appvar, which means unarchiving and re-archiving it,
 * so it is called when leaving a strip and never mid-scroll. Returns false if
 * the write failed, in which case the in-flash copy is unchanged.
 */
bool lib_save_strip(uint16_t index, const lib_strip_t *strip);

/*
 * Expand a title bitmap into the shared scratch buffer.
 *
 * Returns the pixel data, or NULL if the title is unreadable. Only one title is
 * live at a time, which is all the list drawing code needs.
 */
const uint8_t *lib_title(uint16_t offset, uint16_t *width, uint8_t *height);

#endif /* LIBRARY_H */

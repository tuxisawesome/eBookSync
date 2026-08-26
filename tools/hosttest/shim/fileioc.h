#ifndef FILEIOC_H
#define FILEIOC_H

#include "shim.h"

uint8_t ti_Open(const char *name, const char *mode);
int ti_Close(uint8_t handle);
void *ti_GetDataPtr(uint8_t handle);
int ti_Delete(const char *name);
int ti_Seek(int offset, unsigned origin, uint8_t handle);
size_t ti_Write(const void *data, size_t size, size_t count, uint8_t handle);
int ti_SetArchiveStatus(bool archive, uint8_t handle);
uint16_t ti_GetSize(uint8_t handle);
void ti_SetGCBehavior(void (*before)(void), void (*after)(void));

/* Make the shim run a collect on the next archive, to test the handlers. */
void shim_force_gc(void);
bool ti_ArchiveHasRoom(uint24_t num_bytes);

/* Pretend the archive is this big, so the reader's free-space probe has
 * something believable to binary-search. */
void shim_set_archive_free(uint24_t bytes);

#endif /* FILEIOC_H */

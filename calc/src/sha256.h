/*
 * SHA-256.
 *
 * Used for exactly one thing: hashing the calculator's password so the device
 * block holds a digest rather than the password itself. One hash per attempt,
 * so speed is irrelevant and the plain textbook implementation is the right one.
 *
 * The sync page has crypto.subtle.digest('SHA-256', ...) already, which is what
 * the host tests check this against -- an independent implementation of the
 * same standard, which is the discipline the rest of this repository uses for
 * its formats.
 */

#ifndef SHA256_H
#define SHA256_H

#include <stddef.h>
#include <stdint.h>

#define SHA256_SIZE 32

typedef struct {
    uint32_t state[8];
    uint32_t length;        /* bytes absorbed; a password is never near 2^32 */
    uint8_t buffer[64];
    uint8_t held;
} sha256_t;

void sha256_init(sha256_t *ctx);
void sha256_update(sha256_t *ctx, const void *data, size_t length);
void sha256_final(sha256_t *ctx, uint8_t out[SHA256_SIZE]);

/* The whole thing in one call, which is all the password code ever needs. */
void sha256(const void *data, size_t length, uint8_t out[SHA256_SIZE]);

#endif /* SHA256_H */

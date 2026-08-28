#include "chat.h"

#include "library.h"

#include <fileioc.h>
#include <stdlib.h>
#include <string.h>

/* --- the conversation table -------------------------------------------- */

#define TBL_MAGIC     0
#define TBL_VERSION   4
#define TBL_COUNT     5
#define TBL_NEXT_SEQ  6
#define TBL_HEADER    12
#define TBL_RECORD    24

/* Within one table record. */
#define REC_ID        0
#define REC_LAST      2
#define REC_BYTES     6
#define REC_NAME      8

/* --- one stored message ------------------------------------------------- */

#define MSG_SERVER_ID 0
#define MSG_SENT_AT   4
#define MSG_FLAGS     8
#define MSG_SENDER_LEN 9
#define MSG_BODY_LEN  10
#define MSG_HEADER    11

/* --- the outbox --------------------------------------------------------- */

#define OUT_MAGIC     0
#define OUT_VERSION   4
#define OUT_COUNT     5
#define OUT_HEADER    8

#define OUTREC_CONV   0
#define OUTREC_SEQ    2
#define OUTREC_AT     6
#define OUTREC_LEN    10
#define OUTREC_HEADER 11

static const uint8_t *table;
static uint16_t table_size;
static uint8_t conversation_count;

static uint16_t read16(const uint8_t *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static uint32_t read32(const uint8_t *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static void put16(uint8_t *p, uint16_t value) {
    p[0] = (uint8_t)value;
    p[1] = (uint8_t)(value >> 8);
}

static void put32(uint8_t *p, uint32_t value) {
    p[0] = (uint8_t)value;
    p[1] = (uint8_t)(value >> 8);
    p[2] = (uint8_t)(value >> 16);
    p[3] = (uint8_t)(value >> 24);
}

/* Map a variable and keep the flash pointer; nothing is copied. */
static const uint8_t *map(const char *name, uint16_t *size) {
    uint8_t handle = ti_Open(name, "r");
    if (!handle)
        return NULL;

    *size = (uint16_t)ti_GetSize(handle);
    const uint8_t *data = ti_GetDataPtr(handle);
    ti_Close(handle);
    return data;
}

static bool store(const char *name, const uint8_t *data, uint32_t length) {
    ti_Delete(name);

    uint8_t handle = ti_Open(name, "w");
    if (!handle)
        return false;

    bool ok = length == 0 || ti_Write(data, (size_t)length, 1, handle) == 1;
    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);
    if (!ok)
        ti_Delete(name);
    return ok;
}

bool chat_open(void) {
    table = NULL;
    table_size = 0;
    conversation_count = 0;

    uint16_t size;
    const uint8_t *data = map(CHAT_TABLE_NAME, &size);
    if (!data || size < TBL_HEADER ||
        memcmp(data + TBL_MAGIC, CHAT_TABLE_MAGIC, 4) != 0 ||
        data[TBL_VERSION] != CHAT_VERSION)
        return false;

    uint8_t count = data[TBL_COUNT];
    if (count > CHAT_MAX_CONVERSATIONS ||
        (uint32_t)TBL_HEADER + (uint32_t)count * TBL_RECORD > size)
        return false;

    table = data;
    table_size = size;
    conversation_count = count;
    return true;
}

uint8_t chat_conversation_count(void) { return conversation_count; }

static const uint8_t *record(uint8_t index) {
    return table + TBL_HEADER + (uint24_t)index * TBL_RECORD;
}

void chat_get_conversation(uint8_t index, chat_conversation_t *out) {
    memset(out, 0, sizeof *out);
    if (index >= conversation_count)
        return;

    const uint8_t *entry = record(index);
    out->id = read16(entry + REC_ID);
    out->last_server_id = read32(entry + REC_LAST);
    out->bytes = read16(entry + REC_BYTES);
    memcpy(out->name, entry + REC_NAME, CHAT_NAME_MAX);
    out->name[CHAT_NAME_MAX] = '\0';
}

int8_t chat_find(uint16_t conversation_id) {
    for (uint8_t i = 0; i < conversation_count; i++) {
        if (read16(record(i) + REC_ID) == conversation_id)
            return (int8_t)i;
    }
    return -1;
}

/* EOSC<nn>: one conversation's messages. */
static void log_name(char *name, uint8_t index) {
    static const char hex[] = "0123456789ABCDEF";
    name[0] = 'E';
    name[1] = 'O';
    name[2] = 'S';
    name[3] = 'C';
    name[4] = hex[index >> 4];
    name[5] = hex[index & 0x0F];
    name[6] = '\0';
}

/*
 * Step over one packed message. Returns 0 for a record that does not fit,
 * which is what stops a truncated or malicious log walking off the end.
 */
static uint16_t message_size(const uint8_t *at, uint32_t left) {
    if (left < MSG_HEADER)
        return 0;

    uint16_t total = MSG_HEADER + at[MSG_SENDER_LEN] + at[MSG_BODY_LEN];
    if (at[MSG_SENDER_LEN] > CHAT_SENDER_MAX || at[MSG_BODY_LEN] > CHAT_BODY_MAX ||
        total > left)
        return 0;
    return total;
}

uint16_t chat_message_count(uint8_t conversation) {
    char name[7];
    log_name(name, conversation);

    uint16_t size;
    const uint8_t *data = map(name, &size);
    if (!data)
        return 0;

    uint16_t count = 0;
    uint32_t at = 0;
    while (at < size) {
        uint16_t step = message_size(data + at, size - at);
        if (!step)
            break;
        at += step;
        count++;
    }
    return count;
}

bool chat_get_message(uint8_t conversation, uint16_t index, chat_message_t *out) {
    char name[7];
    log_name(name, conversation);

    uint16_t size;
    const uint8_t *data = map(name, &size);
    if (!data)
        return false;

    uint32_t at = 0;
    for (uint16_t i = 0; at < size; i++) {
        const uint8_t *entry = data + at;
        uint16_t step = message_size(entry, size - at);
        if (!step)
            return false;

        if (i == index) {
            memset(out, 0, sizeof *out);
            out->server_id = read32(entry + MSG_SERVER_ID);
            out->sent_at = read32(entry + MSG_SENT_AT);
            out->flags = entry[MSG_FLAGS];

            uint8_t sender_len = entry[MSG_SENDER_LEN];
            memcpy(out->sender, entry + MSG_HEADER, sender_len);
            out->sender[sender_len] = '\0';

            uint8_t body_len = entry[MSG_BODY_LEN];
            memcpy(out->body, entry + MSG_HEADER + sender_len, body_len);
            out->body[body_len] = '\0';
            return true;
        }
        at += step;
    }
    return false;
}

bool chat_put_table(const uint8_t *data, uint32_t length) {
    if (length < TBL_HEADER || memcmp(data + TBL_MAGIC, CHAT_TABLE_MAGIC, 4) != 0 ||
        data[TBL_VERSION] != CHAT_VERSION)
        return false;

    uint8_t count = data[TBL_COUNT];
    if (count > CHAT_MAX_CONVERSATIONS ||
        (uint32_t)TBL_HEADER + (uint32_t)count * TBL_RECORD > length)
        return false;

    /*
     * The computer does not know how far this calculator has read, or how much
     * each conversation is holding -- it sends zeros there. Carry the live
     * values across, the same way the library index carries its device block.
     */
    uint32_t size = TBL_HEADER + (uint32_t)count * TBL_RECORD;
    uint8_t *merged = malloc(size);
    if (!merged)
        return false;
    memcpy(merged, data, size);

    /* Keep the outbox counter: reusing a sequence number would make the relay
     * treat a new message as one it had already seen. */
    if (table)
        memcpy(merged + TBL_NEXT_SEQ, table + TBL_NEXT_SEQ, 4);

    for (uint8_t i = 0; i < count; i++) {
        uint8_t *entry = merged + TBL_HEADER + (uint24_t)i * TBL_RECORD;
        int8_t was = chat_find(read16(entry + REC_ID));
        if (was < 0)
            continue;

        const uint8_t *old = record((uint8_t)was);
        memcpy(entry + REC_LAST, old + REC_LAST, 4);
        memcpy(entry + REC_BYTES, old + REC_BYTES, 2);
    }

    bool ok = store(CHAT_TABLE_NAME, merged, size);
    free(merged);
    chat_open();
    return ok;
}

/* Rewrite one table record's read position and size. */
static bool update_record(uint8_t index, uint32_t last_server_id, uint16_t bytes) {
    uint8_t handle = ti_Open(CHAT_TABLE_NAME, "r+");
    if (!handle)
        return false;

    uint8_t fields[6];
    put32(fields, last_server_id);
    put16(fields + 4, bytes);

    uint24_t offset = TBL_HEADER + (uint24_t)index * TBL_RECORD + REC_LAST;
    bool ok = ti_Seek(offset, SEEK_SET, handle) != EOF
              && ti_Write(fields, sizeof fields, 1, handle) == 1;
    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);

    chat_open();
    return ok;
}

bool chat_append(uint16_t conversation_id, const uint8_t *records, uint32_t length) {
    int8_t index = chat_find(conversation_id);
    if (index < 0)
        return false;

    /* Refuse a batch that does not parse rather than storing a log that cannot
     * be walked afterwards. */
    uint32_t at = 0;
    uint32_t newest = 0;
    while (at < length) {
        uint16_t step = message_size(records + at, length - at);
        if (!step)
            return false;
        newest = read32(records + at + MSG_SERVER_ID);
        at += step;
    }
    if (!length)
        return true;

    char name[7];
    log_name(name, (uint8_t)index);

    uint16_t existing = 0;
    const uint8_t *current = map(name, &existing);

    /*
     * Built on the heap rather than in a static buffer. Eight kilobytes of BSS
     * would be eight kilobytes the band cache never gets, permanently, for
     * something that happens only during a sync -- and render_free() has
     * already handed the cache back by then.
     */
    uint8_t *rebuilt = malloc(CHAT_CONVERSATION_MAX);
    if (!rebuilt)
        return false;
    uint16_t kept = 0;

    if (current && existing) {
        uint32_t want = (uint32_t)existing + length;
        uint32_t drop = want > CHAT_CONVERSATION_MAX ? want - CHAT_CONVERSATION_MAX : 0;

        /* Only whole messages, or the log stops parsing at the first record. */
        uint32_t from = 0;
        while (from < drop && from < existing) {
            uint16_t step = message_size(current + from, existing - from);
            if (!step)
                break;
            from += step;
        }

        kept = (uint16_t)(existing - from);
        if (kept > CHAT_CONVERSATION_MAX)
            kept = 0;
        else
            memcpy(rebuilt, current + from, kept);
    }

    if ((uint32_t)kept + length > CHAT_CONVERSATION_MAX) {
        /* A single batch bigger than the cap: keep its tail, nothing older. */
        kept = 0;
        uint32_t from = 0;
        while (length - from > CHAT_CONVERSATION_MAX) {
            uint16_t step = message_size(records + from, length - from);
            if (!step) {
                free(rebuilt);
                return false;
            }
            from += step;
        }
        memcpy(rebuilt, records + from, length - from);
        kept = (uint16_t)(length - from);
    } else {
        memcpy(rebuilt + kept, records, length);
        kept = (uint16_t)(kept + length);
    }

    bool ok = store(name, rebuilt, kept);
    free(rebuilt);
    if (!ok)
        return false;

    return update_record((uint8_t)index, newest, kept);
}

/* ------------------------------------------------------------------ outbox */

static const uint8_t *outbox(uint16_t *size, uint8_t *count) {
    const uint8_t *data = map(CHAT_OUTBOX_NAME, size);
    if (!data || *size < OUT_HEADER ||
        memcmp(data + OUT_MAGIC, CHAT_OUTBOX_MAGIC, 4) != 0 ||
        data[OUT_VERSION] != CHAT_VERSION) {
        *count = 0;
        return NULL;
    }
    *count = data[OUT_COUNT];
    return data;
}

static uint16_t outbox_record_size(const uint8_t *at, uint32_t left) {
    if (left < OUTREC_HEADER)
        return 0;
    uint16_t total = OUTREC_HEADER + at[OUTREC_LEN];
    if (at[OUTREC_LEN] > CHAT_BODY_MAX || total > left)
        return 0;
    return total;
}

uint16_t chat_outbox_count(void) {
    uint16_t size;
    uint8_t count;
    return outbox(&size, &count) ? count : 0;
}

uint16_t chat_outbox_bytes(void) {
    uint16_t size;
    uint8_t count;
    return outbox(&size, &count) ? size : 0;
}

bool chat_outbox_get(uint16_t index, uint8_t *out, uint16_t *length) {
    uint16_t size;
    uint8_t count;
    const uint8_t *data = outbox(&size, &count);
    if (!data || index >= count)
        return false;

    uint32_t at = OUT_HEADER;
    for (uint16_t i = 0; at < size; i++) {
        uint16_t step = outbox_record_size(data + at, size - at);
        if (!step)
            return false;
        if (i == index) {
            memcpy(out, data + at, step);
            *length = step;
            return true;
        }
        at += step;
    }
    return false;
}

bool chat_outbox_message(uint16_t index, chat_queued_t *out) {
    uint8_t record[OUTREC_HEADER + CHAT_BODY_MAX];
    uint16_t length = 0;
    if (!chat_outbox_get(index, record, &length) || length < OUTREC_HEADER)
        return false;

    memset(out, 0, sizeof *out);
    out->conversation_id = read16(record + OUTREC_CONV);
    out->seq = read32(record + OUTREC_SEQ);
    out->composed_at = read32(record + OUTREC_AT);

    uint8_t body_len = record[OUTREC_LEN];
    if (body_len > CHAT_BODY_MAX)
        body_len = CHAT_BODY_MAX;
    memcpy(out->body, record + OUTREC_HEADER, body_len);
    out->body[body_len] = '\0';
    return true;
}

uint16_t chat_outbox_count_for(uint16_t conversation_id) {
    uint16_t total = chat_outbox_count();
    uint16_t mine = 0;

    for (uint16_t i = 0; i < total; i++) {
        chat_queued_t queued;
        if (!chat_outbox_message(i, &queued))
            break;
        if (queued.conversation_id == conversation_id)
            mine++;
    }
    return mine;
}

/*
 * The next sequence number, and it must never go backwards.
 *
 * The computer turns it into the relay's idempotency key, so a repeat would
 * make the relay treat a new message as one it had already stored -- and
 * silently drop it. Seeded from the clock the first time, so an outbox that is
 * deleted and recreated does not start again from one.
 */
static uint32_t next_sequence(void) {
    if (table) {
        uint32_t seq = read32(table + TBL_NEXT_SEQ);
        if (seq)
            return seq;
    }
    return lib_now();
}

static bool set_next_sequence(uint32_t seq) {
    if (!table)
        return false;

    uint8_t handle = ti_Open(CHAT_TABLE_NAME, "r+");
    if (!handle)
        return false;

    uint8_t field[4];
    put32(field, seq);
    bool ok = ti_Seek(TBL_NEXT_SEQ, SEEK_SET, handle) != EOF
              && ti_Write(field, sizeof field, 1, handle) == 1;
    ok = ti_SetArchiveStatus(true, handle) && ok;
    ti_Close(handle);

    chat_open();
    return ok;
}

bool chat_send(uint16_t conversation_id, const char *body) {
    if (chat_find(conversation_id) < 0)
        return false;

    uint8_t length = (uint8_t)strlen(body);
    if (!length)
        return false;
    if (length > CHAT_BODY_MAX)
        length = CHAT_BODY_MAX;

    uint16_t size = 0;
    uint8_t count = 0;
    const uint8_t *current = outbox(&size, &count);

    uint8_t *rebuilt = malloc(CHAT_OUTBOX_MAX);
    if (!rebuilt)
        return false;
    uint16_t used = OUT_HEADER;

    if (current) {
        used = size;
        memcpy(rebuilt, current, size);
    } else {
        memset(rebuilt, 0, OUT_HEADER);
        memcpy(rebuilt + OUT_MAGIC, CHAT_OUTBOX_MAGIC, 4);
        rebuilt[OUT_VERSION] = CHAT_VERSION;
        count = 0;
    }

    if ((uint32_t)used + OUTREC_HEADER + length > CHAT_OUTBOX_MAX || count == 0xFF) {
        free(rebuilt);
        return false;
    }

    uint32_t seq = next_sequence();

    uint8_t *entry = rebuilt + used;
    put16(entry + OUTREC_CONV, conversation_id);
    put32(entry + OUTREC_SEQ, seq);
    put32(entry + OUTREC_AT, lib_now());
    entry[OUTREC_LEN] = length;
    memcpy(entry + OUTREC_HEADER, body, length);

    used = (uint16_t)(used + OUTREC_HEADER + length);
    rebuilt[OUT_COUNT] = (uint8_t)(count + 1);

    bool ok = store(CHAT_OUTBOX_NAME, rebuilt, used);
    free(rebuilt);
    if (!ok)
        return false;

    set_next_sequence(seq + 1);
    return true;
}

bool chat_outbox_drop(uint16_t count) {
    uint16_t size;
    uint8_t held;
    const uint8_t *data = outbox(&size, &held);
    if (!data)
        return true;

    if (count >= held) {
        ti_Delete(CHAT_OUTBOX_NAME);
        return true;
    }

    uint32_t at = OUT_HEADER;
    for (uint16_t i = 0; i < count && at < size; i++) {
        uint16_t step = outbox_record_size(data + at, size - at);
        if (!step)
            break;
        at += step;
    }

    uint8_t *rebuilt = malloc(CHAT_OUTBOX_MAX);
    if (!rebuilt)
        return false;

    memcpy(rebuilt, data, OUT_HEADER);
    rebuilt[OUT_COUNT] = (uint8_t)(held - count);
    memcpy(rebuilt + OUT_HEADER, data + at, size - at);

    bool ok = store(CHAT_OUTBOX_NAME, rebuilt, OUT_HEADER + (size - at));
    free(rebuilt);
    return ok;
}

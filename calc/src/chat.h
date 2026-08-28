/*
 * Chat on the calculator.
 *
 * The calculator has no network. Everything here moves at sync time: the
 * computer hands over what has arrived since last time, and takes away whatever
 * has been typed. See docs/PROTOCOL.md for the commands and docs/FORMAT.md for
 * the records.
 *
 * Three appvars, all archived, all read in place from flash the way csx.c reads
 * comics -- nothing here is ever staged in RAM whole.
 *
 *   EOSCHT      the conversations: id, name, how far each has been read
 *   EOSC<nn>    one conversation's messages, append-only
 *   EOSOUT      the outbox: typed here, not yet handed over
 *
 * Flash is the comics' budget, so a conversation is capped and the oldest
 * messages are dropped when it fills. The cap is small for a second reason: an
 * append has to unarchive the whole variable into RAM, and during a sync there
 * is already a 16 KB payload buffer and a 16 KB variable being built next to it.
 */

#ifndef CHAT_H
#define CHAT_H

#include <stdbool.h>
#include <stdint.h>

#define CHAT_TABLE_NAME   "EOSCHT"
#define CHAT_OUTBOX_NAME  "EOSOUT"
#define CHAT_TABLE_MAGIC  "ECH1"
#define CHAT_OUTBOX_MAGIC "EOU1"
#define CHAT_VERSION      1

/* Per calculator, not per person: a menu of sixteen is already more than
 * anyone will scroll through on a 320x240 screen. */
#define CHAT_MAX_CONVERSATIONS 16

/*
 * What one conversation may hold, and what one message may be.
 *
 * 8 KB is about two hundred short messages. It is deliberately far below what
 * the archive could spare, because appending unarchives the whole variable into
 * RAM and a sync is already holding 32 KB of the fifty-odd that exist.
 */
#define CHAT_CONVERSATION_MAX 8192
#define CHAT_BODY_MAX         200
#define CHAT_SENDER_MAX       12
#define CHAT_NAME_MAX         16

/* The outbox is small: it is drained on every sync. */
#define CHAT_OUTBOX_MAX       2048

#define CHAT_FLAG_MINE  0x01

typedef struct {
    uint16_t id;                    /* the relay's conversation id */
    uint32_t last_server_id;        /* the newest message stored here */
    uint16_t bytes;                 /* how much of the cap is used */
    char name[CHAT_NAME_MAX + 1];
} chat_conversation_t;

typedef struct {
    uint32_t server_id;
    uint32_t sent_at;
    uint8_t flags;
    char sender[CHAT_SENDER_MAX + 1];
    char body[CHAT_BODY_MAX + 1];
} chat_message_t;

/* One message typed here and still waiting for a sync to carry it away. */
typedef struct {
    uint16_t conversation_id;
    uint32_t seq;
    uint32_t composed_at;
    char body[CHAT_BODY_MAX + 1];
} chat_queued_t;

/* Map the conversation table. False when there has never been a sync. */
bool chat_open(void);

uint8_t chat_conversation_count(void);
void chat_get_conversation(uint8_t index, chat_conversation_t *out);

/* -1 when the relay's id is not one this calculator knows about. */
int8_t chat_find(uint16_t conversation_id);

/*
 * Walk one conversation's messages, newest last.
 *
 * `index` counts from the oldest message still stored. Returns false past the
 * end. The record is copied out because the caller wants a terminated string
 * and flash holds neither.
 */
uint16_t chat_message_count(uint8_t conversation);
bool chat_get_message(uint8_t conversation, uint16_t index, chat_message_t *out);

/* Replace the conversation table with what the computer just sent. */
bool chat_put_table(const uint8_t *data, uint32_t length);

/*
 * Append packed message records to one conversation.
 *
 * Drops the oldest whole messages if that would go over the cap, which is the
 * only way a conversation can stay bounded without the computer having to know
 * how much room the calculator has left.
 */
bool chat_append(uint16_t conversation_id, const uint8_t *records, uint32_t length);

/* ---------------------------------------------------------------- outbox */

uint16_t chat_outbox_count(void);
uint16_t chat_outbox_bytes(void);

/* One queued message, packed as the wire format. False past the end. */
bool chat_outbox_get(uint16_t index, uint8_t *out, uint16_t *length);

/*
 * The same, decoded, so the reader can show what is still waiting.
 *
 * Without this a message vanishes the moment it is written: it is in the
 * outbox, which nothing draws, and it does not reach the conversation log until
 * it has been to the relay and come back on a later sync. Two syncs of silence
 * looks exactly like having lost it.
 */
bool chat_outbox_message(uint16_t index, chat_queued_t *out);

/* How many are waiting for one conversation. */
uint16_t chat_outbox_count_for(uint16_t conversation_id);

/* Queue something typed here. False if the outbox is full. */
bool chat_send(uint16_t conversation_id, const char *body);

/*
 * Drop the first `count` queued messages.
 *
 * Called when the computer has stored them durably -- not when they reach the
 * relay. If the network is down they are still safely off the calculator, and
 * the relay's own de-duplication makes a retry free.
 */
bool chat_outbox_drop(uint16_t count);

#endif /* CHAT_H */

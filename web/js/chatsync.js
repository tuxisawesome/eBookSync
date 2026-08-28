/*
 * The chat half of a sync.
 *
 * Runs against any computer. Only the comics care which computer they came
 * from -- mixing two libraries would leave the calculator holding strips the
 * page cannot account for -- but the chat belongs to whoever's account this
 * page is signed in as, and the calculator is a second terminal for it.
 *
 * Order matters, and it is: take first, then give.
 *
 *   1. ask what the calculator has and what it has queued
 *   2. take the queue, store it here, and only then tell the calculator to
 *      drop it
 *   3. push the conversation list
 *   4. push whatever is newer than the calculator's read position
 *
 * Step 2 is the one that has to be in that order. Acknowledging before storing
 * would lose messages if the page died in between; storing before acknowledging
 * can at worst store them twice, and the relay de-duplicates on clientId.
 */

import { calculatorClientId } from './chat.js';
import * as wire from './chatwire.js';
import { UPDATE_CHUNK_SIZE } from './link.js';

/* One CHAT_IN_PUT must fit the calculator's payload buffer, and a record must
 * never be split across two of them. */
const BATCH_LIMIT = UPDATE_CHUNK_SIZE;

/**
 * Take everything the calculator has queued.
 *
 * Returns the messages in the shape the relay's batch endpoint wants. The
 * acknowledgement is the caller's job, once they are stored.
 */
export async function collect(calculator, state, userId) {
  const taken = [];

  for (let i = 0; i < state.outboxCount; i++) {
    const record = await calculator.chatOutGet(i);
    if (!record) break;

    taken.push({
      conversationId: record.conversationId,
      body: record.body,
      clientId: calculatorClientId(userId, record.seq),
      sentAt: record.composedAt,
      fromCalculator: true,
    });
  }

  return taken;
}

/**
 * What each conversation is missing, newest-last and capped.
 *
 * The calculator holds a bounded tail of each conversation, so there is no
 * point sending more than it can keep -- everything older would be dropped on
 * arrival, having cost a flash write on the way.
 */
export function outstanding(messages, state, conversations, userId) {
  const known = new Map(state.conversations.map((c) => [c.id, c.lastServerId]));
  const wanted = new Set(conversations.map((c) => c.id));

  const byConversation = new Map();
  for (const message of messages) {
    if (!wanted.has(message.conversationId)) continue;
    if (message.id <= (known.get(message.conversationId) || 0)) continue;

    if (!byConversation.has(message.conversationId)) {
      byConversation.set(message.conversationId, []);
    }
    byConversation.get(message.conversationId).push({
      serverId: message.id,
      sentAt: message.sentAt,
      mine: message.userId === userId,
      sender: message.displayName || message.username || '',
      body: message.body,
    });
  }

  for (const list of byConversation.values()) list.sort((a, b) => a.serverId - b.serverId);
  return byConversation;
}

/**
 * Run the whole exchange.
 *
 * `store` is chatstore.js. `onStatus` is called with something worth showing.
 * Returns what happened, so the caller can report it rather than guess.
 */
export async function exchange(calculator, store, {
  userId = 0,
  onStatus = () => {},
} = {}) {
  const summary = { taken: 0, sent: 0, conversations: 0, skipped: null };

  const state = await calculator.chatState();
  summary.conversations = state.conversations.length;

  /* --- take what is queued ------------------------------------------- */
  if (state.outboxCount) {
    onStatus(`Taking ${state.outboxCount} message(s) off the calculator…`);
    const taken = await collect(calculator, state, userId);

    /* Stored here before the calculator is told to let go of them. */
    await store.queue(taken);
    await calculator.chatOutAck(taken.length);
    summary.taken = taken.length;
  }

  /* --- push the conversation list ------------------------------------ */
  const conversations = await store.conversations();
  if (!conversations.length) {
    summary.skipped = 'no conversations yet -- sign in to the relay first';
    return summary;
  }

  onStatus('Sending the conversation list…');
  await calculator.chatPutRoster(wire.packTable(conversations));

  /*
   * Ask again. The table it had a moment ago may have been empty, or missing
   * conversations that have since been created -- and a CHAT_IN_PUT for a
   * conversation the calculator does not know about is refused.
   */
  const after = await calculator.chatState();

  /* --- push what it has not got --------------------------------------- */
  const missing = outstanding(await store.messages(), after,
                              conversations.slice(0, wire.MAX_CONVERSATIONS), userId);

  for (const [conversationId, list] of missing) {
    const batches = wire.batchMessages(list, BATCH_LIMIT);
    for (let i = 0; i < batches.length; i++) {
      onStatus(`Sending messages… ${summary.sent + batches[i].length}`);
      await calculator.chatPutMessages(conversationId, wire.packMessages(batches[i]));
      summary.sent += batches[i].length;
    }
  }

  await store.setCalculatorState({
    conversations: after.conversations,
    syncedAt: Math.floor(Date.now() / 1000),
  });

  return summary;
}

/**
 * Send anything waiting to the relay, and forget it once it is there.
 *
 * Separate from the calculator exchange on purpose: the two fail
 * independently, and a calculator sync should not be held up by a relay that is
 * unreachable, nor the other way round.
 */
export async function drain(relay, store, { onStatus = () => {} } = {}) {
  const waiting = await store.pending();
  if (!waiting.length) return { uploaded: 0 };

  onStatus(`Sending ${waiting.length} message(s) to the relay…`);
  const fromCalculator = waiting.some((item) => item.fromCalculator);

  const result = await relay.sendBatch(
    waiting.map(({ conversationId, body, clientId, sentAt }) =>
      ({ conversationId, body, clientId, sentAt })),
    { fromCalculator },
  );

  await store.clearPending(waiting.map((item) => item.clientId));
  return { uploaded: waiting.length, created: result.created };
}

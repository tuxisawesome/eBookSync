/*
 * The chat format, both implementations.
 *
 * web/js/chatwire.js packs the records and calc/src/chat.c stores and reads
 * them back. Neither has seen the other's code, which is the only reason
 * agreement here means anything -- the same discipline the library index and
 * the .csx container are held to.
 *
 * It also covers the two behaviours that are easy to get wrong and invisible
 * until they bite: that a conversation stays under its cap by dropping whole
 * messages from the front, and that the outbox's sequence numbers never repeat.
 *
 *   node tools/hosttest/check_chat.mjs
 */

import { execFileSync } from 'node:child_process';
import { existsSync, mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import * as wire from '../../web/js/chatwire.js';
import { writeAppvar } from '../../web/js/tifile.js';

const HERE = dirname(fileURLToPath(import.meta.url));

let failures = 0;
let checks = 0;

function check(label, actual, expected) {
  checks++;
  const a = JSON.stringify(actual);
  const b = JSON.stringify(expected);
  if (a !== b) {
    failures++;
    console.log(`  FAIL ${label}: got ${a}, want ${b}`);
  }
}

function run(directory, args) {
  const output = execFileSync(join(HERE, 'chat_probe'), [directory, ...args],
                              { encoding: 'utf8' });
  return output.split('\n').filter(Boolean);
}

function parse(lines, keyword) {
  return lines.filter((line) => line.startsWith(`${keyword} `))
    .map((line) => line.slice(keyword.length + 1));
}

/** A calculator holding a table the computer just pushed. */
function seeded(conversations) {
  const directory = mkdtempSync(join(tmpdir(), 'eos-chat-'));
  const table = join(directory, 'table.bin');
  writeFileSync(table, wire.packTable(conversations));
  run(directory, ['table', table, 'save']);
  return { directory, table };
}

function messagesFile(directory, name, messages) {
  const path = join(directory, name);
  writeFileSync(path, wire.packMessages(messages));
  return path;
}

/* --- the table round-trips ------------------------------------------------ */
{
  const { directory } = seeded([
    { id: 3, name: 'Study group' },
    { id: 9, name: 'sam' },
  ]);

  const lines = run(directory, ['list']);
  check('the reader sees both conversations', parse(lines, 'conversations'), ['2']);
  check('with their ids and names', parse(lines, 'conversation'),
        ['3 0 0 Study group', '9 0 0 sam']);

  /* The stored table must be readable by the browser's parser too, or a future
   * change could quietly diverge in only one direction. */
  const stored = readFileSync(join(directory, 'EOSCHT.bin'));
  const parsed = wire.parseTable(new Uint8Array(stored));
  check('and the browser reads back what the reader stored',
        parsed.conversations.map((c) => [c.id, c.name]), [[3, 'Study group'], [9, 'sam']]);
}

/* --- messages arrive and are read back ------------------------------------ */
{
  const { directory } = seeded([{ id: 3, name: 'Study group' }]);

  const messages = [
    { serverId: 10, sentAt: 1_700_000_000, mine: false, sender: 'sam', body: 'are you there' },
    { serverId: 11, sentAt: 1_700_000_060, mine: true, sender: 'walter', body: 'yes' },
  ];
  const lines = run(directory, [
    'append', '3', messagesFile(directory, 'in.bin', messages),
    'messages', '0', 'list', 'save',
  ]);

  check('the batch was accepted', parse(lines, 'append'), ['1']);
  check('both messages are there', parse(lines, 'messages'), ['2']);
  check('with their senders, bodies and flags', parse(lines, 'message'), [
    '10 1700000000 0 sam|are you there',
    '11 1700000060 1 walter|yes',
  ]);
  check('and the conversation records how far it has read',
        parse(lines, 'conversation')[0].split(' ')[1], '11');

  /* And the log the reader wrote parses with the browser's parser. */
  const stored = new Uint8Array(readFileSync(join(directory, 'EOSC00.bin')));
  check('the browser reads the stored log',
        wire.parseMessages(stored).map((m) => m.body), ['are you there', 'yes']);
}

/* --- a conversation stays under its cap ----------------------------------- */
/*
 * Flash is the comics' budget. A chat that grew without limit would quietly
 * cost strips, and the calculator is the only end that knows how much room it
 * has -- so trimming has to happen here, and has to drop whole messages or the
 * log stops parsing at the first partial record.
 */
{
  const { directory } = seeded([{ id: 3, name: 'Big' }]);
  const CAP = 8192;

  const wall = [];
  for (let i = 0; i < 200; i++) {
    wall.push({
      serverId: 1000 + i,
      sentAt: 1_700_000_000 + i,
      mine: false,
      sender: 'sam',
      body: `message number ${i} `.padEnd(120, 'x'),
    });
  }

  /* In batches, the way a real sync sends them. */
  const batches = wire.batchMessages(wall, 16384);
  const args = [];
  batches.forEach((batch, i) => {
    args.push('append', '3', messagesFile(directory, `w${i}.bin`, batch));
  });
  const lines = run(directory, [...args, 'messages', '0', 'list', 'save']);

  check('every batch was accepted',
        parse(lines, 'append').every((v) => v === '1'), true);

  const stored = readFileSync(join(directory, 'EOSC00.bin'));
  check('the log stayed under the cap', stored.length <= CAP, true);
  check('and it is close to it rather than emptied', stored.length > CAP / 2, true);

  /* The crucial part: what is left still parses, and it is the newest end. */
  const kept = wire.parseMessages(new Uint8Array(stored));
  check('what is left still parses as whole messages',
        kept.length, Number(parse(lines, 'messages')[0]));
  check('and it is the newest messages that survived',
        kept[kept.length - 1].serverId, 1199);
  check('the oldest were dropped', kept[0].serverId > 1000, true);
  check('the conversation still records the newest id',
        parse(lines, 'conversation')[0].split(' ')[1], '1199');

  /*
   * The discriminating case: one more message onto an almost-full log.
   *
   * Staying under the cap is not enough on its own -- throwing the whole log
   * away and keeping only the new batch would also do that, and would silently
   * lose the conversation every time it filled. What has to happen is that just
   * enough is dropped from the front.
   */
  const before = wire.parseMessages(new Uint8Array(readFileSync(join(directory, 'EOSC00.bin'))));
  const one = messagesFile(directory, 'one.bin', [{
    serverId: 2000, sentAt: 1_700_100_000, mine: true, sender: 'walter', body: 'ok',
  }]);
  run(directory, ['append', '3', one, 'save']);

  const after = wire.parseMessages(new Uint8Array(readFileSync(join(directory, 'EOSC00.bin'))));
  check('one more message costs roughly one message',
        after.length >= before.length - 2, true);
  check('rather than the whole conversation', after.length > 10, true);
  check('and the new one is on the end', after[after.length - 1].serverId, 2000);
  check('while the front is still the older history', after[0].serverId < 1199, true);
}

/* --- the outbox ----------------------------------------------------------- */
{
  const { directory } = seeded([{ id: 3, name: 'Study group' }, { id: 9, name: 'sam' }]);

  const lines = run(directory, [
    'send', '3', 'typed on the calculator',
    'send', '9', 'and another',
    'outbox', 'save',
  ]);

  check('both were queued', parse(lines, 'send'), ['1', '1']);
  check('the outbox reports two', parse(lines, 'outbox')[0].split(' ')[0], '2');

  const queued = parse(lines, 'queued').map((line) => {
    const parts = line.split(' ');
    const bytes = Uint8Array.from(parts.slice(1).map((hex) => parseInt(hex, 16)));
    return wire.parseOutboxRecord(bytes);
  });

  check('the browser reads the queued records',
        queued.map((q) => [q.conversationId, q.body]),
        [[3, 'typed on the calculator'], [9, 'and another']]);

  /*
   * Sequence numbers must not repeat. The computer turns them into the relay's
   * idempotency key, so a repeat would make the relay treat a new message as
   * one it had already stored -- and drop it without a word.
   */
  check('sequence numbers differ', queued[0].seq !== queued[1].seq, true);
  check('and they increase', queued[1].seq > queued[0].seq, true);
}

/* --- acknowledging drops the front, and only the front ------------------- */
{
  const { directory } = seeded([{ id: 3, name: 'Study group' }]);

  const after = run(directory, [
    'send', '3', 'first', 'send', '3', 'second', 'send', '3', 'third',
    'drop', '2', 'outbox',
  ]);

  check('two were dropped', parse(after, 'drop'), ['1']);
  check('one is left', parse(after, 'outbox')[0].split(' ')[0], '1');

  const left = parse(after, 'queued').map((line) => {
    const parts = line.split(' ');
    return wire.parseOutboxRecord(Uint8Array.from(parts.slice(1).map((h) => parseInt(h, 16))));
  });
  check('and it is the newest one', left.map((q) => q.body), ['third']);
}

/* --- a sequence number is not reused after an acknowledgement ------------- */
{
  const { directory } = seeded([{ id: 3, name: 'Study group' }]);

  const first = run(directory, ['send', '3', 'one', 'outbox', 'save']);
  const firstSeq = wire.parseOutboxRecord(Uint8Array.from(
    parse(first, 'queued')[0].split(' ').slice(1).map((h) => parseInt(h, 16)))).seq;

  const second = run(directory, ['drop', '1', 'send', '3', 'two', 'outbox', 'save']);
  const secondSeq = wire.parseOutboxRecord(Uint8Array.from(
    parse(second, 'queued')[0].split(' ').slice(1).map((h) => parseInt(h, 16)))).seq;

  check('an emptied outbox does not start counting again', secondSeq > firstSeq, true);
}

/* --- a pushed table does not lose what the calculator knows --------------- */
/*
 * The computer replaces the whole table on every sync and sends zeros where the
 * read positions go, because it does not know them. If they were not carried
 * across, every sync would re-send every message the calculator already had.
 */
{
  const { directory } = seeded([{ id: 3, name: 'Study group' }]);

  const messages = [{ serverId: 42, sentAt: 1, mine: false, sender: 'sam', body: 'hi' }];
  run(directory, ['append', '3', messagesFile(directory, 'in.bin', messages), 'save']);

  const again = join(directory, 'table2.bin');
  writeFileSync(again, wire.packTable([
    { id: 3, name: 'Study group renamed' },
    { id: 9, name: 'sam' },
  ]));
  const lines = run(directory, ['table', again, 'list', 'messages', '0']);

  check('the new table was accepted', parse(lines, 'table'), ['1']);
  const conversations = parse(lines, 'conversation');
  /* Names are cut to sixteen characters, which is what fits beside the rest of
   * a row on a 320-pixel screen. */
  check('the rename came through, cut to the name limit',
        conversations[0].endsWith('Study group rena'), true);
  check('the read position survived', conversations[0].split(' ')[1], '42');
  check('the new conversation starts at nothing', conversations[1].split(' ')[1], '0');
  check('and the messages are still there', parse(lines, 'messages'), ['1']);
}

/* --- nonsense is refused rather than stored ------------------------------- */
{
  const { directory } = seeded([{ id: 3, name: 'Study group' }]);

  const truncated = join(directory, 'bad.bin');
  const good = wire.packMessages([
    { serverId: 1, sentAt: 1, mine: false, sender: 'sam', body: 'hello there' },
  ]);
  writeFileSync(truncated, good.subarray(0, good.length - 3));

  const lines = run(directory, ['append', '3', truncated, 'messages', '0']);
  check('a truncated batch is refused', parse(lines, 'append'), ['0']);
  check('and nothing was stored', parse(lines, 'messages'), ['0']);

  const unknown = messagesFile(directory, 'other.bin', [
    { serverId: 1, sentAt: 1, mine: false, sender: 'sam', body: 'hi' },
  ]);
  check('a batch for an unknown conversation is refused',
        parse(run(directory, ['append', '77', unknown]), 'append'), ['0']);
  check('and so is sending to one',
        parse(run(directory, ['send', '77', 'hello']), 'send'), ['0']);
}

/* --- text the calculator cannot draw is folded before it is sent ---------- */
{
  check('CJK becomes a question mark', wire.toCalculatorText('第一本书'), '?');
  check('accents are flattened rather than lost', wire.toCalculatorText('café'), 'cafe');
  check('newlines become spaces', wire.toCalculatorText('a\nb'), 'a b');
  check('runs of dropped characters collapse', wire.toCalculatorText('a 第一本书 b'), 'a ? b');
  check('a body is cut to the calculator\'s limit',
        wire.toCalculatorText('x'.repeat(400), wire.BODY_MAX).length, wire.BODY_MAX);
}


/* --- what is queued is visible before it has been anywhere ---------------- */
/*
 * A message typed on the calculator goes into the outbox, which nothing used to
 * draw, and does not reach the conversation log until it has been to the relay
 * and come back on a later sync. Two syncs of silence looks exactly like having
 * lost it, so the reader shows the queue as part of the conversation.
 */
{
  const { directory } = seeded([{ id: 3, name: 'Study' }, { id: 9, name: 'sam' }]);

  const lines = run(directory, [
    'send', '3', 'first to study',
    'send', '9', 'one to sam',
    'send', '3', 'second to study',
    'waiting', '3', 'save',
  ]);

  check('the count is per conversation', parse(lines, 'waiting'), ['3 2']);
  check('and it decodes the bodies in order',
        parse(lines, 'waits').map((l) => l.split(' ').slice(2).join(' ')),
        ['first to study', 'second to study']);

  const other = run(directory, ['waiting', '9']);
  check('the other conversation has its own', parse(other, 'waiting'), ['9 1']);
  check('with only its own message',
        parse(other, 'waits').map((l) => l.split(' ').slice(2).join(' ')),
        ['one to sam']);

  const none = run(directory, ['waiting', '77']);
  check('a conversation with nothing queued says so', parse(none, 'waiting'), ['77 0']);

  /* Once a sync has taken them, the conversation stops claiming they are
   * waiting -- otherwise it would show every message twice for ever. */
  const after = run(directory, ['drop', '3', 'waiting', '3', 'save']);
  check('an acknowledged queue is empty again', parse(after, 'waiting'), ['3 0']);
  check('and nothing is left waiting', parse(after, 'waits'), []);
}

console.log(`${checks - failures}/${checks} chat checks pass`);
process.exit(failures ? 1 : 0);

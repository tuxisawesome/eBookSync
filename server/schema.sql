-- The eOS chat relay.
--
-- Two things here carry more weight than they look.
--
-- messages.id is a single monotonic sequence across every conversation, so
-- every client -- the PWA, the sync page, and the calculator behind it -- tracks
-- one integer and asks for "everything after N". Per-conversation cursors would
-- need one integer per conversation on a device with 50 KB of RAM.
--
-- messages.client_id is unique, so redelivery is free. A sync that dies after
-- the relay accepted a calculator's message but before the acknowledgement got
-- back is retried on the next sync, and produces one row rather than two.

CREATE TABLE IF NOT EXISTS users (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    username        TEXT NOT NULL UNIQUE,
    display_name    TEXT NOT NULL,
    pw_hash         BLOB NOT NULL,
    pw_salt         BLOB NOT NULL,
    is_admin        INTEGER NOT NULL DEFAULT 0,

    -- Set the first time a sync computer relays for this account, so other
    -- people can see that someone is reading on a calculator and when they last
    -- picked their messages up.
    has_calculator  INTEGER NOT NULL DEFAULT 0,
    last_calc_sync  INTEGER,

    disabled        INTEGER NOT NULL DEFAULT 0,
    created_at      INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS conversations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    kind        TEXT NOT NULL CHECK (kind IN ('direct', 'group')),
    name        TEXT,
    created_by  INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at  INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS members (
    conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at       INTEGER NOT NULL,
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS messages (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id         INTEGER REFERENCES users(id) ON DELETE SET NULL,
    body            TEXT NOT NULL,
    sent_at         INTEGER NOT NULL,
    client_id       TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS tokens (
    hash        BLOB PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label       TEXT NOT NULL,
    created_at  INTEGER NOT NULL,
    last_used   INTEGER
);

-- Reading is always "this conversation, after this id", which is what these
-- serve. Everything else here is small enough not to care.
CREATE INDEX IF NOT EXISTS messages_by_conversation
    ON messages (conversation_id, id);
CREATE INDEX IF NOT EXISTS members_by_user
    ON members (user_id);

# The eOS chat relay

A small Flask service that holds the chat history, serves a PWA people talk
through, and lets an administrator add and remove users.

The calculator never talks to this. It has no network — only a cable — so the
sync page relays for it: messages typed on the calculator go up on the next
sync, and messages sent here come down on the one after that.

## What it is not

The sync page is still static, still serverless, still fine opened straight off
disk. This is a separate service. Nothing about reading comics needs it.

## Requirements

**Flask, and nothing else.** `scrypt`, `sqlite3`, `secrets` and `json` are all
standard library. On PythonAnywhere, Flask is already there, so in practice
there is nothing to install.

## Deploying to PythonAnywhere

TLS and the reverse proxy come with the account, which is the whole reason for
choosing it: the sync page is served from GitHub Pages over HTTPS, and a browser
will not let an HTTPS page talk to a plain-HTTP server.

1. Upload the repository, or clone it from a Bash console.
2. Make a web app with the **Manual configuration** option, Python 3.10+.
3. Edit the WSGI configuration file it made, replacing everything with:

   ```python
   import os
   import sys

   sys.path.insert(0, "/home/YOU/eBookSync")

   os.environ["EOS_DB_PATH"] = "/home/YOU/eos.db"
   os.environ["EOS_SECRET_KEY"] = "paste-something-random-here"
   os.environ["EOS_ALLOWED_ORIGINS"] = "https://YOU.github.io"

   from server.wsgi import application       # noqa: E402
   ```

4. Reload the web app, open `https://YOU.pythonanywhere.com/admin/login`, and
   create the first administrator. That offer disappears as soon as one exists.
5. Add people in **People**, open conversations in **Conversations**, and put
   the relay's address into the sync page's chat settings.

**Keep the database outside the source tree.** `EOS_DB_PATH` above points at
your home directory on purpose — a redeploy that overwrote the chat history
would be difficult to notice and impossible to undo.

**Set `EOS_SECRET_KEY`.** Without it the app generates a random one on every
start, which signs administrators out on every reload. Nothing else uses it;
chat tokens do not depend on it.

**`EOS_ALLOWED_ORIGINS`** is the exact origin of your sync page, scheme and all,
comma-separated if there is more than one. The `Authorization` header makes
every cross-origin request preflighted, so a missing entry here shows up as the
sync page being unable to reach the relay at all.

Free accounts need renewing every three months, and the site goes quiet if you
forget.

## Polling, and why there is no WebSocket

PythonAnywhere does not support WebSockets. The clients poll `/api/messages`
every three seconds while visible and every thirty when hidden, backing off when
the relay is unreachable. This is a deliberate accommodation of the host, not an
oversight — check what your host actually supports before changing it.

## The API

Bearer tokens in `Authorization`, JSON in and out. `POST /api/login` is the only
route that does not need one.

| | |
|---|---|
| `POST /api/login` | `{username, password}` → `{token, user}` |
| `POST /api/logout` | revokes the token used |
| `GET /api/me` | the user, their conversations, the roster |
| `GET /api/roster` | who exists, and who reads on a calculator |
| `GET /api/messages?since=N` | everything after `N` in conversations you are in |
| `POST /api/messages` | `{conversationId, body, clientId}` |
| `POST /api/messages/batch` | a calculator's outbox, relayed by the sync page |
| `POST /api/calc/sync` | records that a calculator synced |

Two design points carry the weight:

**One cursor.** `messages.id` is a single sequence across every conversation, so
a client tracks one integer. That is what lets a calculator with 50 KB of RAM
keep its place without one number per conversation. The cursor a client is given
back is the last id it was *shown*, never the relay's high-water mark — a
message in somebody else's conversation must not skip it past its own.

**`clientId` is unique.** Redelivery is therefore free. A sync that dies after
the relay accepted a calculator's messages but before the acknowledgement got
back is simply retried, and produces the same rows rather than duplicates.

Membership is checked on every read and every write. A conversation you are not
in answers 404, not 403: 403 would confirm it exists.

## Administration

`/admin`, signed in with a session cookie rather than a chat token, so a token
that leaked out of a client cannot reach it.

- **People** — add, disable, delete, reset a password, grant or remove
  administrator. A generated password is shown once and never again.
- **Conversations** — create and rename groups, add and remove members, and open
  direct conversations. Direct conversations are made here rather than by the
  clients so there is exactly one per pair.

Disabling keeps someone's history and signs them out everywhere. Deleting
removes the account and leaves their messages unattributed — the other half of a
conversation would be unreadable otherwise.

You cannot disable, delete, or un-admin yourself, which is the only thing
standing between an administrator and a relay nobody can administer.

## Tests

```sh
python3 -m unittest discover -s server/tests -t .
```

Real SQLite, real Flask, real routing — nothing mocked. scrypt is weakened in
the tests only, because the production parameters take tens of milliseconds and
the suite signs in dozens of times.

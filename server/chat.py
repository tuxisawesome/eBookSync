"""What a conversation is, and who is allowed to see it.

Kept apart from the HTTP layer so the rules can be read in one place. There is
one rule and it is enforced on every read and every write: you can only touch a
conversation you are a member of.

A conversation you are not in comes back as 404 rather than 403 throughout. 403
would confirm it exists, and "which groups is this person in" is not something a
relay should answer to people who are not in them.
"""

from . import db

BODY_LIMIT = 2000
BATCH_LIMIT = 200
PAGE_LIMIT = 200


class NotFound(Exception):
    """Either it does not exist or you cannot see it -- deliberately the same."""


class BadRequest(Exception):
    def __init__(self, message):
        super().__init__(message)
        self.message = message


def is_member(conversation_id, user_id):
    return db.query(
        "SELECT 1 FROM members WHERE conversation_id = ? AND user_id = ?",
        (conversation_id, user_id),
        one=True,
    ) is not None


def require_member(conversation_id, user_id):
    if not is_member(conversation_id, user_id):
        raise NotFound()


def conversations_for(user_id):
    rows = db.query(
        """SELECT c.id, c.kind, c.name,
                  (SELECT MAX(id) FROM messages m WHERE m.conversation_id = c.id) AS last_id
           FROM conversations c
           JOIN members ON members.conversation_id = c.id
           WHERE members.user_id = ?
           ORDER BY c.id""",
        (user_id,),
    )

    # Everyone in all of them, in one go. This used to be a query per
    # conversation, run on every poll of /api/me -- the classic shape that is
    # fine with two conversations and is not with twenty.
    everyone = db.query(
        """SELECT members.conversation_id, users.id, users.username,
                  users.display_name
           FROM members
           JOIN users ON users.id = members.user_id
           WHERE members.conversation_id IN (
               SELECT conversation_id FROM members WHERE user_id = ?)
           ORDER BY users.username""",
        (user_id,),
    )

    by_conversation = {}
    for member in everyone:
        by_conversation.setdefault(member["conversation_id"], []).append({
            "id": member["id"],
            "username": member["username"],
            "display_name": member["display_name"],
        })

    out = []
    for row in rows:
        members = by_conversation.get(row["id"], [])
        out.append({
            "id": row["id"],
            "kind": row["kind"],
            "name": display_name(row, members, user_id),
            "lastId": row["last_id"] or 0,
            "members": members,
        })
    return out


def display_name(conversation, members, viewer_id):
    """What to call a conversation, from this viewer's side.

    A direct conversation has no name of its own -- it is "the other person",
    and which person that is depends on who is asking.
    """
    if conversation["kind"] == "group":
        return conversation["name"] or "Group"

    others = [m for m in members if m["id"] != viewer_id]
    if others:
        return others[0]["display_name"] or others[0]["username"]
    return "Notes to self"


def roster():
    """Everyone, with whether they read on a calculator and when it last synced."""
    rows = db.query(
        """SELECT id, username, display_name, has_calculator, last_calc_sync
           FROM users WHERE disabled = 0 ORDER BY username"""
    )
    return [{
        "id": row["id"],
        "username": row["username"],
        "displayName": row["display_name"],
        "hasCalculator": bool(row["has_calculator"]),
        "lastCalcSync": row["last_calc_sync"],
    } for row in rows]


def messages_since(user_id, since=0, limit=PAGE_LIMIT):
    """Everything after `since` in conversations this user is in.

    One query across every conversation, because clients track one cursor. The
    join to members is what keeps the rule above true for reads.
    """
    limit = max(1, min(int(limit), PAGE_LIMIT))
    rows = db.query(
        """SELECT m.id, m.conversation_id, m.body, m.sent_at, m.client_id,
                  m.user_id, users.username, users.display_name
           FROM messages m
           JOIN members ON members.conversation_id = m.conversation_id
                       AND members.user_id = ?
           LEFT JOIN users ON users.id = m.user_id
           WHERE m.id > ?
           ORDER BY m.id
           LIMIT ?""",
        (user_id, int(since), limit),
    )
    return [serialise(row) for row in rows]


def serialise(row):
    return {
        "id": row["id"],
        "conversationId": row["conversation_id"],
        "body": row["body"],
        "sentAt": row["sent_at"],
        "clientId": row["client_id"],
        "userId": row["user_id"],
        "username": row["username"],
        "displayName": row["display_name"] or row["username"],
    }


def post(user_id, conversation_id, body, client_id, sent_at=None):
    """Store one message, or return the existing one with the same client_id.

    Idempotent on purpose. A calculator's outbox is handed over before it is
    known to have reached the relay, so the same message can legitimately be
    offered twice; the second time must be free rather than a duplicate.
    """
    body = (body or "").strip()
    if not body:
        raise BadRequest("a message cannot be empty")
    if len(body) > BODY_LIMIT:
        raise BadRequest(f"a message cannot be longer than {BODY_LIMIT} characters")
    if not client_id or len(client_id) > 64:
        raise BadRequest("clientId must be 1-64 characters")

    require_member(conversation_id, user_id)

    existing = db.query(
        "SELECT * FROM messages WHERE client_id = ?", (client_id,), one=True)
    if existing is not None:
        row = db.query(
            """SELECT m.*, users.username, users.display_name FROM messages m
               LEFT JOIN users ON users.id = m.user_id WHERE m.id = ?""",
            (existing["id"],), one=True)
        return serialise(row), False

    when = int(sent_at) if sent_at else db.now()
    message_id = db.execute(
        """INSERT INTO messages (conversation_id, user_id, body, sent_at, client_id)
           VALUES (?, ?, ?, ?, ?)""",
        (conversation_id, user_id, body, when, client_id),
    )

    row = db.query(
        """SELECT m.*, users.username, users.display_name FROM messages m
           LEFT JOIN users ON users.id = m.user_id WHERE m.id = ?""",
        (message_id,), one=True)
    return serialise(row), True


def note_calculator_sync(user_id, when=None):
    """Record that a calculator picked its messages up, for the roster."""
    db.execute(
        "UPDATE users SET has_calculator = 1, last_calc_sync = ? WHERE id = ?",
        (int(when) if when else db.now(), user_id),
    )

"""The JSON API, spoken by both the PWA and the sync page.

Everything is bearer-token authenticated except /api/login. The sync page runs
on a different origin -- GitHub Pages -- so every route here has to survive a
CORS preflight; app.py handles that in one place.
"""

from functools import wraps

from flask import Blueprint, jsonify, request

from . import auth, chat, db

bp = Blueprint("api", __name__, url_prefix="/api")


def authenticated(view):
    @wraps(view)
    def wrapper(*args, **kwargs):
        user = auth.current_user()
        if user is None:
            return jsonify(error="not signed in"), 401
        return view(user, *args, **kwargs)
    return wrapper


@bp.errorhandler(chat.NotFound)
def _not_found(_error):
    return jsonify(error="no such conversation"), 404


@bp.errorhandler(chat.BadRequest)
def _bad_request(error):
    return jsonify(error=error.message), 400


def body():
    return request.get_json(silent=True) or {}


def describe(user):
    return {
        "id": user["id"],
        "username": user["username"],
        "displayName": user["display_name"],
        "isAdmin": bool(user["is_admin"]),
        "hasCalculator": bool(user["has_calculator"]),
        "lastCalcSync": user["last_calc_sync"],
    }


@bp.post("/login")
def login():
    data = body()
    username = str(data.get("username", "")).strip().lower()
    password = str(data.get("password", ""))

    row = db.query("SELECT * FROM users WHERE username = ? AND disabled = 0",
                   (username,), one=True)

    # The same answer whether the account does not exist or the password is
    # wrong. Telling them apart is a list of who has an account here.
    if row is None or not auth.check_password(password, row["pw_hash"], row["pw_salt"]):
        return jsonify(error="wrong username or password"), 401

    label = str(data.get("label", "browser"))[:40] or "browser"
    return jsonify(token=auth.issue_token(row["id"], label), user=describe(row))


@bp.post("/logout")
@authenticated
def logout(_user):
    token = auth.bearer()
    if token:
        auth.revoke_token(token)
    return jsonify(ok=True)


@bp.get("/me")
@authenticated
def me(user):
    return jsonify(
        user=describe(user),
        conversations=chat.conversations_for(user["id"]),
        roster=chat.roster(),
        cursor=latest_id(),
    )


@bp.get("/roster")
@authenticated
def roster(_user):
    return jsonify(roster=chat.roster())


def latest_id():
    row = db.query("SELECT MAX(id) AS id FROM messages", one=True)
    return (row["id"] if row and row["id"] else 0)


@bp.get("/messages")
@authenticated
def messages(user):
    since = request.args.get("since", 0)
    limit = request.args.get("limit", chat.PAGE_LIMIT)
    try:
        since = int(since)
        limit = int(limit)
    except (TypeError, ValueError):
        return jsonify(error="since and limit must be numbers"), 400

    found = chat.messages_since(user["id"], since, limit)

    # The cursor is the last id actually returned, not the relay's high-water
    # mark: a message in someone else's conversation must not advance this
    # client past messages it has not been given yet.
    cursor = found[-1]["id"] if found else since
    return jsonify(messages=found, cursor=cursor, more=len(found) == min(limit, chat.PAGE_LIMIT))


@bp.post("/messages")
@authenticated
def send(user):
    data = body()
    try:
        conversation_id = int(data.get("conversationId", 0))
    except (TypeError, ValueError):
        return jsonify(error="conversationId must be a number"), 400

    message, created = chat.post(
        user["id"], conversation_id, data.get("body"), data.get("clientId"))
    return jsonify(message=message, created=created)


@bp.post("/messages/batch")
@authenticated
def send_batch(user):
    """Hand over a calculator's outbox.

    Every message carries the clientId the calculator minted, so a batch that
    was accepted but whose acknowledgement never got back can be sent again
    without duplicating anything. That is the entire reason this is not just a
    loop over /api/messages on the client.
    """
    data = body()
    items = data.get("messages")
    if not isinstance(items, list):
        return jsonify(error="messages must be a list"), 400
    if len(items) > chat.BATCH_LIMIT:
        return jsonify(error=f"at most {chat.BATCH_LIMIT} messages at a time"), 400

    stored = []
    created = 0
    for item in items:
        if not isinstance(item, dict):
            return jsonify(error="each message must be an object"), 400
        try:
            conversation_id = int(item.get("conversationId", 0))
        except (TypeError, ValueError):
            return jsonify(error="conversationId must be a number"), 400

        message, was_new = chat.post(
            user["id"], conversation_id, item.get("body"), item.get("clientId"),
            item.get("sentAt"))
        stored.append(message)
        created += 1 if was_new else 0

    if data.get("fromCalculator"):
        chat.note_calculator_sync(user["id"])

    return jsonify(messages=stored, created=created, cursor=latest_id())


@bp.post("/calc/sync")
@authenticated
def calc_sync(user):
    """A calculator has just synced, so other people can see it happened."""
    chat.note_calculator_sync(user["id"])
    return jsonify(ok=True, at=db.now())

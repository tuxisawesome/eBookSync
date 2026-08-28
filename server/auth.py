"""Passwords and tokens.

scrypt from hashlib and secrets from the standard library, so there is nothing
to install beyond Flask itself. That matters more than it sounds on a host where
the deploy is "upload the files and reload the web app".

Tokens are opaque random strings, stored as their SHA-256 rather than in the
clear: a stolen copy of the database is then not a set of working logins. They
do not expire. On a relay for a handful of people an expiry only ever fires
while someone is mid-conversation, and revoking is a row delete away.
"""

import hashlib
import hmac
import secrets

from flask import g, request

from . import db

# scrypt's defaults from RFC 7914, which take a few tens of milliseconds here.
# n has to be a power of two, and the work is n * r * 2 * 64 bytes of memory --
# about 32 MB at these numbers, which is the point of it.
SCRYPT = {"n": 16384, "r": 8, "p": 1}
SALT_SIZE = 16
TOKEN_BYTES = 32


def hash_password(password, salt=None):
    salt = salt or secrets.token_bytes(SALT_SIZE)
    digest = hashlib.scrypt(password.encode(), salt=salt, dklen=32, **SCRYPT)
    return digest, salt


def check_password(password, digest, salt):
    candidate, _ = hash_password(password, bytes(salt))
    return hmac.compare_digest(candidate, bytes(digest))


def token_hash(token):
    return hashlib.sha256(token.encode()).digest()


def issue_token(user_id, label="browser"):
    token = secrets.token_urlsafe(TOKEN_BYTES)
    db.execute(
        "INSERT INTO tokens (hash, user_id, label, created_at) VALUES (?, ?, ?, ?)",
        (token_hash(token), user_id, label, db.now()),
    )
    return token


def revoke_token(token):
    db.execute("DELETE FROM tokens WHERE hash = ?", (token_hash(token),))


def bearer():
    """The token on this request, or None."""
    header = request.headers.get("Authorization", "")
    scheme, _, value = header.partition(" ")
    return value.strip() if scheme.lower() == "bearer" and value.strip() else None


def user_for_token(token):
    row = db.query(
        """SELECT users.* FROM tokens
           JOIN users ON users.id = tokens.user_id
           WHERE tokens.hash = ? AND users.disabled = 0""",
        (token_hash(token),),
        one=True,
    )
    if row is not None:
        db.execute("UPDATE tokens SET last_used = ? WHERE hash = ?",
                   (db.now(), token_hash(token)))
    return row


def current_user():
    """The authenticated user for this request, or None. Cached per request."""
    if "user" in g:
        return g.user

    token = bearer()
    g.user = user_for_token(token) if token else None
    return g.user

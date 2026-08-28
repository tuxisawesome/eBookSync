"""SQLite, in WAL mode, with one connection per request.

PythonAnywhere runs a handful of worker processes against one file, which WAL
handles comfortably at this size -- a chat between a few people is not a load.
What it does not tolerate is a transaction held open across a request, so every
write here is a single short `with connection` block.
"""

import os
import sqlite3
import time
from pathlib import Path

from flask import current_app, g

SCHEMA = Path(__file__).with_name("schema.sql")

DEFAULT_PATH = os.environ.get("EOS_DB_PATH", str(Path(__file__).with_name("eos.db")))


def now():
    """Unix seconds. One definition, so stored times cannot disagree."""
    return int(time.time())


def explain_path(path):
    """Why SQLite cannot open `path`, in words, or None if it looks fine.

    "unable to open database file" is one of the least helpful messages in
    computing: it is the same whether the directory does not exist, the path is
    a typo, or the disk is read-only. Nearly always it is the first, and nearly
    always on a fresh deploy it is a placeholder left in the WSGI file.
    """
    target = Path(path)
    parent = target.parent

    if not parent.exists():
        hint = ""
        if "YOU" in str(parent) or "yourusername" in str(parent).lower():
            hint = (" That looks like the placeholder from server/README.md -- "
                    "put your own PythonAnywhere username in EOS_DB_PATH.")
        return (f"the folder {parent} does not exist, so the database cannot be "
                f"created there.{hint}")

    if not parent.is_dir():
        return f"{parent} is a file, not a folder, so nothing can be created inside it."

    if not os.access(parent, os.W_OK):
        return f"the folder {parent} is not writable by this process."

    if target.exists() and not os.access(target, os.W_OK):
        return f"{target} exists but is not writable by this process."

    return None


def connect(path):
    try:
        connection = sqlite3.connect(path, timeout=10)
    except sqlite3.OperationalError as error:
        # Re-raise with the reason attached. The database creates itself, so
        # anything that fails here is about the path, not about the schema.
        reason = explain_path(path)
        raise sqlite3.OperationalError(
            f"could not open the database at {path}: "
            f"{reason or error}"
        ) from error

    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA journal_mode = WAL")
    connection.execute("PRAGMA foreign_keys = ON")
    # Long enough to ride out a slow write, short enough that a jam surfaces as
    # an error the client can retry rather than a browser hanging with no
    # explanation. Reads do not take the write lock at all any more -- see
    # auth.TOUCH_AFTER -- so reaching this at all is now unusual.
    connection.execute("PRAGMA busy_timeout = 4000")
    return connection


def get():
    """The connection for this request, opened on first use."""
    if "db" not in g:
        g.db = connect(current_app.config["DB_PATH"])
    return g.db


def close(_exception=None):
    connection = g.pop("db", None)
    if connection is not None:
        connection.close()


def initialise(path):
    """Create the database and its schema if they are not there.

    Run on every start, and safe to: `CREATE TABLE IF NOT EXISTS` throughout, so
    an existing database is left exactly as it was. There is nothing to create
    by hand -- see "The database" in server/README.md.
    """
    connection = connect(path)
    try:
        with connection:
            connection.executescript(SCHEMA.read_text())
    finally:
        connection.close()


def query(sql, args=(), one=False):
    cursor = get().execute(sql, args)
    rows = cursor.fetchall()
    cursor.close()
    if one:
        return rows[0] if rows else None
    return rows


def execute(sql, args=()):
    """Run one statement in its own transaction, returning the new rowid."""
    connection = get()
    with connection:
        cursor = connection.execute(sql, args)
        return cursor.lastrowid

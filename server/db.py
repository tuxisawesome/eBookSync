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


def connect(path):
    connection = sqlite3.connect(path, timeout=10)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA journal_mode = WAL")
    connection.execute("PRAGMA foreign_keys = ON")
    connection.execute("PRAGMA busy_timeout = 10000")
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
    """Create the schema if it is not there. Safe to run on every start."""
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

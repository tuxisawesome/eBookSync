"""Create and inspect the relay's database from a console.

The web app creates the database itself on every start, so in the normal case
there is nothing to run here. This exists for the case that is not normal: a
`unable to open database file` on startup, where the useful thing is to try the
same path from a shell and be told exactly what is wrong.

    python3 -m server.manage check        # where is it, can it be written, what is in it
    python3 -m server.manage init         # create it, or leave an existing one alone

Both take the path from EOS_DB_PATH, or --path, so they test the same setting
the web app uses rather than a guess at it.
"""

import argparse
import os
import sqlite3
import sys
from pathlib import Path

from . import db


def resolve(path):
    return path or os.environ.get("EOS_DB_PATH") or db.DEFAULT_PATH


def check(path):
    target = Path(path)
    print(f"path          {target}")
    print(f"from          {'--path' if path else ('EOS_DB_PATH' if os.environ.get('EOS_DB_PATH') else 'the built-in default')}")
    print(f"folder        {target.parent}")

    problem = db.explain_path(path)
    if problem:
        print(f"\nThis will not work: {problem}")
        if not target.parent.exists():
            print(f"\nEither create it:\n    mkdir -p {target.parent}")
            print("or point EOS_DB_PATH somewhere that exists, in your web app's")
            print("WSGI configuration file, and reload the web app.")
        return 1

    print("writable      yes")

    if not target.exists():
        print("exists        no -- it will be created on the next start,")
        print("                    or now with: python3 -m server.manage init")
        return 0

    print(f"exists        yes ({target.stat().st_size} bytes)")

    connection = db.connect(path)
    try:
        tables = [row[0] for row in connection.execute(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name")]
        if not tables:
            print("tables        none -- run init")
            return 0

        print(f"tables        {', '.join(tables)}")
        for table in ("users", "conversations", "messages"):
            if table in tables:
                count = connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
                print(f"  {table:<13} {count}")

        admins = connection.execute(
            "SELECT username FROM users WHERE is_admin = 1 ORDER BY username").fetchall()
        if admins:
            print(f"administrators {', '.join(row[0] for row in admins)}")
        else:
            print("administrators none -- open /admin/login to make the first one")
    finally:
        connection.close()

    return 0


def initialise(path):
    problem = db.explain_path(path)
    if problem:
        print(f"Cannot create the database: {problem}", file=sys.stderr)
        return 1

    existed = Path(path).exists()
    db.initialise(path)
    print(f"{'Checked' if existed else 'Created'} {path}")
    if not existed:
        print("Now open /admin/login on the site to make the first administrator.")
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("command", choices=("check", "init"))
    parser.add_argument("--path", help="override EOS_DB_PATH")
    args = parser.parse_args(argv)

    path = resolve(args.path)
    try:
        return check(path) if args.command == "check" else initialise(path)
    except sqlite3.Error as error:
        print(f"{error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

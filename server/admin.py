"""The admin panel: who exists, and which groups they are in.

Server-rendered, session-cookie authenticated, and deliberately separate from
the JSON API. It is used from a browser by one person occasionally, so a form
post and a redirect is the right shape -- and it means an admin session cannot
be reached with a bearer token that leaked out of a chat client.

Bootstrapping: with no users at all, the first visit offers to create an admin.
That is the only way in on a fresh install, and it closes as soon as one exists.
"""

import secrets

from flask import (Blueprint, flash, redirect, render_template, request,
                   session, url_for)

from . import auth, db

bp = Blueprint("admin", __name__, url_prefix="/admin")


def user_count():
    return db.query("SELECT COUNT(*) AS n FROM users", one=True)["n"]


def signed_in():
    user_id = session.get("admin_user")
    if not user_id:
        return None
    return db.query(
        "SELECT * FROM users WHERE id = ? AND is_admin = 1 AND disabled = 0",
        (user_id,), one=True)


def require_admin():
    user = signed_in()
    if user is None:
        return None, redirect(url_for("admin.login"))
    return user, None


def clean_username(raw):
    username = str(raw or "").strip().lower()
    if not username or len(username) > 32:
        raise ValueError("a username must be 1-32 characters")
    if not all(c.isalnum() or c in "-_." for c in username):
        raise ValueError("a username may only hold letters, digits, - _ and .")
    return username


@bp.get("/login")
def login():
    if user_count() == 0:
        return render_template("admin/bootstrap.html")
    return render_template("admin/login.html")


@bp.post("/login")
def do_login():
    username = str(request.form.get("username", "")).strip().lower()
    password = str(request.form.get("password", ""))

    row = db.query("SELECT * FROM users WHERE username = ? AND disabled = 0",
                   (username,), one=True)
    if row is None or not auth.check_password(password, row["pw_hash"], row["pw_salt"]):
        flash("Wrong username or password.")
        return redirect(url_for("admin.login"))
    if not row["is_admin"]:
        flash("That account is not an administrator.")
        return redirect(url_for("admin.login"))

    session["admin_user"] = row["id"]
    return redirect(url_for("admin.users"))


@bp.post("/bootstrap")
def bootstrap():
    """Create the first administrator. Only ever available on an empty relay."""
    if user_count() != 0:
        flash("There are already users; sign in instead.")
        return redirect(url_for("admin.login"))

    try:
        username = clean_username(request.form.get("username"))
    except ValueError as error:
        flash(str(error))
        return redirect(url_for("admin.login"))

    password = str(request.form.get("password", ""))
    if len(password) < 8:
        flash("Pick a password of at least 8 characters.")
        return redirect(url_for("admin.login"))

    create_user(username, username, password, is_admin=True)
    flash("Administrator created. Sign in.")
    return redirect(url_for("admin.login"))


@bp.get("/logout")
def logout():
    session.pop("admin_user", None)
    return redirect(url_for("admin.login"))


def create_user(username, display_name, password, is_admin=False):
    digest, salt = auth.hash_password(password)
    return db.execute(
        """INSERT INTO users (username, display_name, pw_hash, pw_salt, is_admin,
                              created_at)
           VALUES (?, ?, ?, ?, ?, ?)""",
        (username, display_name or username, digest, salt, 1 if is_admin else 0,
         db.now()),
    )


@bp.get("/")
@bp.get("/users")
def users():
    admin, bounce = require_admin()
    if bounce:
        return bounce

    return render_template(
        "admin/users.html",
        admin=admin,
        users=db.query("SELECT * FROM users ORDER BY username"),
    )


@bp.post("/users/new")
def add_user():
    admin, bounce = require_admin()
    if bounce:
        return bounce

    try:
        username = clean_username(request.form.get("username"))
    except ValueError as error:
        flash(str(error))
        return redirect(url_for("admin.users"))

    if db.query("SELECT 1 FROM users WHERE username = ?", (username,), one=True):
        flash(f"There is already a user called {username}.")
        return redirect(url_for("admin.users"))

    # A generated password if none was given, shown once. Easier to hand someone
    # a strong password than to ask them to invent one.
    password = str(request.form.get("password", "")) or secrets.token_urlsafe(9)
    display = str(request.form.get("display_name", "")).strip() or username

    create_user(username, display, password,
                is_admin=bool(request.form.get("is_admin")))
    flash(f"Created {username} with password: {password}")
    return redirect(url_for("admin.users"))


@bp.post("/users/<int:user_id>/password")
def reset_password(user_id):
    admin, bounce = require_admin()
    if bounce:
        return bounce

    password = str(request.form.get("password", "")) or secrets.token_urlsafe(9)
    digest, salt = auth.hash_password(password)
    db.execute("UPDATE users SET pw_hash = ?, pw_salt = ? WHERE id = ?",
               (digest, salt, user_id))

    # Every existing sign-in is now stale. That is the point of a reset.
    db.execute("DELETE FROM tokens WHERE user_id = ?", (user_id,))
    flash(f"New password: {password} (everything signed in has been signed out)")
    return redirect(url_for("admin.users"))


@bp.post("/users/<int:user_id>/disable")
def toggle_disabled(user_id):
    admin, bounce = require_admin()
    if bounce:
        return bounce

    if user_id == admin["id"]:
        flash("You cannot disable yourself.")
        return redirect(url_for("admin.users"))

    row = db.query("SELECT disabled FROM users WHERE id = ?", (user_id,), one=True)
    if row is None:
        flash("No such user.")
        return redirect(url_for("admin.users"))

    disabled = 0 if row["disabled"] else 1
    db.execute("UPDATE users SET disabled = ? WHERE id = ?", (disabled, user_id))
    if disabled:
        db.execute("DELETE FROM tokens WHERE user_id = ?", (user_id,))
    flash("User disabled." if disabled else "User enabled.")
    return redirect(url_for("admin.users"))


@bp.post("/users/<int:user_id>/admin")
def toggle_admin(user_id):
    admin, bounce = require_admin()
    if bounce:
        return bounce

    if user_id == admin["id"]:
        flash("You cannot remove your own administrator rights.")
        return redirect(url_for("admin.users"))

    row = db.query("SELECT is_admin FROM users WHERE id = ?", (user_id,), one=True)
    if row is None:
        flash("No such user.")
        return redirect(url_for("admin.users"))

    db.execute("UPDATE users SET is_admin = ? WHERE id = ?",
               (0 if row["is_admin"] else 1, user_id))
    return redirect(url_for("admin.users"))


@bp.post("/users/<int:user_id>/delete")
def delete_user(user_id):
    admin, bounce = require_admin()
    if bounce:
        return bounce

    if user_id == admin["id"]:
        flash("You cannot delete yourself.")
        return redirect(url_for("admin.users"))

    # Their messages stay, with the author blanked -- the schema sets user_id to
    # NULL. Deleting a person's half of a conversation would leave everyone
    # else's half unreadable.
    db.execute("DELETE FROM users WHERE id = ?", (user_id,))
    flash("User deleted. Their messages remain, without a name on them.")
    return redirect(url_for("admin.users"))


@bp.get("/groups")
def groups():
    admin, bounce = require_admin()
    if bounce:
        return bounce

    rows = db.query("SELECT * FROM conversations ORDER BY kind, id")
    listing = []
    for row in rows:
        listing.append({
            "row": row,
            "members": db.query(
                """SELECT users.* FROM members JOIN users ON users.id = members.user_id
                   WHERE members.conversation_id = ? ORDER BY users.username""",
                (row["id"],)),
        })

    return render_template(
        "admin/groups.html",
        admin=admin,
        conversations=listing,
        users=db.query("SELECT * FROM users WHERE disabled = 0 ORDER BY username"),
    )


@bp.post("/groups/new")
def add_group():
    admin, bounce = require_admin()
    if bounce:
        return bounce

    name = str(request.form.get("name", "")).strip()
    if not name:
        flash("A group needs a name.")
        return redirect(url_for("admin.groups"))

    members = request.form.getlist("members")
    conversation_id = db.execute(
        "INSERT INTO conversations (kind, name, created_by, created_at) VALUES "
        "('group', ?, ?, ?)",
        (name[:60], admin["id"], db.now()),
    )
    for user_id in members:
        db.execute(
            "INSERT OR IGNORE INTO members (conversation_id, user_id, joined_at) "
            "VALUES (?, ?, ?)",
            (conversation_id, int(user_id), db.now()))

    flash(f"Created {name}.")
    return redirect(url_for("admin.groups"))


@bp.post("/groups/<int:conversation_id>/rename")
def rename_group(conversation_id):
    admin, bounce = require_admin()
    if bounce:
        return bounce

    name = str(request.form.get("name", "")).strip()
    if name:
        db.execute("UPDATE conversations SET name = ? WHERE id = ? AND kind = 'group'",
                   (name[:60], conversation_id))
    return redirect(url_for("admin.groups"))


@bp.post("/groups/<int:conversation_id>/members")
def change_members(conversation_id):
    admin, bounce = require_admin()
    if bounce:
        return bounce

    user_id = int(request.form.get("user_id", 0))
    if request.form.get("remove"):
        db.execute(
            "DELETE FROM members WHERE conversation_id = ? AND user_id = ?",
            (conversation_id, user_id))
    else:
        db.execute(
            "INSERT OR IGNORE INTO members (conversation_id, user_id, joined_at) "
            "VALUES (?, ?, ?)",
            (conversation_id, user_id, db.now()))
    return redirect(url_for("admin.groups"))


@bp.post("/groups/<int:conversation_id>/delete")
def delete_group(conversation_id):
    admin, bounce = require_admin()
    if bounce:
        return bounce

    db.execute("DELETE FROM conversations WHERE id = ? AND kind = 'group'",
               (conversation_id,))
    flash("Group and its messages deleted.")
    return redirect(url_for("admin.groups"))


@bp.post("/direct")
def add_direct():
    """Open a direct conversation between two people.

    Direct conversations are made here rather than by the clients, so there is
    exactly one per pair and nobody can quietly create a second.
    """
    admin, bounce = require_admin()
    if bounce:
        return bounce

    try:
        a = int(request.form.get("a", 0))
        b = int(request.form.get("b", 0))
    except (TypeError, ValueError):
        flash("Pick two people.")
        return redirect(url_for("admin.groups"))

    if a == b or not a or not b:
        flash("Pick two different people.")
        return redirect(url_for("admin.groups"))

    existing = db.query(
        """SELECT c.id FROM conversations c
           JOIN members m1 ON m1.conversation_id = c.id AND m1.user_id = ?
           JOIN members m2 ON m2.conversation_id = c.id AND m2.user_id = ?
           WHERE c.kind = 'direct'""",
        (a, b), one=True)
    if existing is not None:
        flash("Those two already have a conversation.")
        return redirect(url_for("admin.groups"))

    conversation_id = db.execute(
        "INSERT INTO conversations (kind, name, created_by, created_at) VALUES "
        "('direct', NULL, ?, ?)",
        (admin["id"], db.now()))
    for user_id in (a, b):
        db.execute(
            "INSERT INTO members (conversation_id, user_id, joined_at) VALUES (?, ?, ?)",
            (conversation_id, user_id, db.now()))

    flash("Conversation opened.")
    return redirect(url_for("admin.groups"))

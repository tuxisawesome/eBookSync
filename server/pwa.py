"""Serving the chat client.

It lives on the relay's own origin rather than beside the sync page, for two
reasons: a service worker can only control the origin it was served from, and an
installed app that has to be told a server address before it can do anything is
a worse first run than one that already knows.
"""

from flask import Blueprint, render_template, send_from_directory

bp = Blueprint("pwa", __name__)


@bp.get("/")
def index():
    return render_template("app.html")


@bp.get("/sw.js")
def service_worker():
    # Served from the root rather than /static so it can control the whole
    # origin -- a worker's scope cannot rise above the path it was served from.
    return send_from_directory(
        bp.root_path + "/static", "sw.js", mimetype="text/javascript")


@bp.get("/manifest.webmanifest")
def manifest():
    return send_from_directory(
        bp.root_path + "/static", "manifest.webmanifest",
        mimetype="application/manifest+json")

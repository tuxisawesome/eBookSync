"""The eOS chat relay.

A small Flask app with three jobs: hold the chat history, serve a PWA people can
talk through, and let an admin add and remove users. Flask is the only
dependency -- scrypt, sqlite3 and secrets are all standard library -- because
the deploy target is PythonAnywhere, where "upload the files and reload" is the
whole procedure.

This does not contradict the sync page's "no build step, no server". The page is
still static and still serverless; this is a separate service that the page and
the PWA both talk to, and the calculator never talks to at all -- it has no
network, only a cable.
"""

import os

from flask import Flask, jsonify, request

from . import admin, api, db, pwa

# The sync page runs on GitHub Pages, a different origin, and sends an
# Authorization header -- which makes every request preflighted. Set
# EOS_ALLOWED_ORIGINS to a comma-separated list in the WSGI file.
DEFAULT_ORIGINS = "https://tuxisawesome.github.io"


def create_app(config=None):
    app = Flask(__name__)
    app.config.update(
        DB_PATH=os.environ.get("EOS_DB_PATH", db.DEFAULT_PATH),
        SECRET_KEY=os.environ.get("EOS_SECRET_KEY", ""),
        ALLOWED_ORIGINS=[
            origin.strip()
            for origin in os.environ.get("EOS_ALLOWED_ORIGINS", DEFAULT_ORIGINS).split(",")
            if origin.strip()
        ],
    )
    if config:
        app.config.update(config)

    if not app.config["SECRET_KEY"]:
        # Only the admin panel's session cookie uses this. A random key means
        # admins are signed out on every reload, which is survivable; a fixed
        # default that shipped in the repository would not be.
        app.config["SECRET_KEY"] = os.urandom(32)

    db.initialise(app.config["DB_PATH"])
    app.teardown_appcontext(db.close)

    app.register_blueprint(api.bp)
    app.register_blueprint(admin.bp)
    app.register_blueprint(pwa.bp)

    install_cors(app)

    @app.errorhandler(404)
    def _missing(_error):
        if request.path.startswith("/api/"):
            return jsonify(error="no such endpoint"), 404
        return "Not found", 404

    return app


def install_cors(app):
    """Hand-written CORS, which is about ten lines and one fewer dependency.

    The preflight is not optional: an Authorization header on a cross-origin
    request makes the browser send OPTIONS first, and a relay that only answers
    GET and POST simply does not work from the sync page.
    """

    def allowed():
        origin = request.headers.get("Origin")
        return origin if origin and origin in app.config["ALLOWED_ORIGINS"] else None

    @app.before_request
    def _preflight():
        if request.method == "OPTIONS" and request.path.startswith("/api/"):
            return ("", 204)
        return None

    @app.after_request
    def _headers(response):
        origin = allowed()
        if origin:
            response.headers["Access-Control-Allow-Origin"] = origin
            response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type"
            response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
            response.headers["Access-Control-Max-Age"] = "86400"
            # Caches must not serve one origin's response to another.
            response.headers["Vary"] = "Origin"
        return response


app = create_app()

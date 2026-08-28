"""PythonAnywhere entry point.

In the web app's WSGI configuration file:

    import sys
    sys.path.insert(0, "/home/YOU/eBookSync")

    import os
    os.environ["EOS_DB_PATH"] = "/home/YOU/eos.db"
    os.environ["EOS_SECRET_KEY"] = "..."
    os.environ["EOS_ALLOWED_ORIGINS"] = "https://YOU.github.io"

    from server.wsgi import application

Keep the database outside the source tree, so redeploying cannot overwrite it.
"""

from .app import create_app

application = create_app()

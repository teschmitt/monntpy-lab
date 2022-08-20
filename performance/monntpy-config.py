from pathlib import Path
import os
import subprocess

"""
For running this in CORE Emu Lab, we need to change some of moNNT.py's configuration
This enables us to load a standard config.toml into the applications working path
and then substitute some elements with dynamically generated values that are taken
from the environment or passed to start-monttpy.sh

"""

# SENDER_EMAIL = os.environ.get('SENDER_EMAIL')
SENDER_EMAIL = "monntpy@tu-darmstadt.de"
DB_PATH = os.environ.get('DB_PATH')
# SESSION_DIR = os.environ.get('SESSION_DIR')
# HOSTNAME = subprocess.run(["hostname"], stdout=subprocess.PIPE).stdout.decode().strip()

if DB_PATH.endswith("/"):
    DB_PATH = DB_PATH[:-1]

config = {
        "backend": {"db_url": f"sqlite://{DB_PATH}/db.sqlite3"},
        "dtnd": {
            "host": "http://127.0.0.1",
            "node_id": "dtn://monntpyeval/",
            "port": 3000,
            "rest_path": "",
            "ws_path": "/ws",
            "multi_user": False,
        },
        "backoff": {
            "initial_wait": 0.1,
            "max_retries": 20,
            "reconn_pause": 300,
            "constant_wait": 0.75,
        },
        "bundles": {"lifetime": 86400000, "delivery_notification": False},
        "usenet": {
            "expiry_time": 86400000,
            "email": SENDER_EMAIL,
            "newsgroups": [
                "monntpy.eval",
            ],
        },
    }
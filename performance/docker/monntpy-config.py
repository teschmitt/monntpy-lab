from pathlib import Path
import os
import subprocess

"""
For running this in CORE Emu Lab, we need to change some of moNNT.py's configuration
This enables us to load a standard config.toml into the applications working path
and then substitute some elements with dynamically generated values that are taken
from the environment or passed to start-monttpy.sh

"""

SENDER_EMAIL = "monntpy@tu-darmstadt.de"
DB_PATH = os.environ.get('DB_PATH')

if DB_PATH.endswith("/"):
    DB_PATH = DB_PATH[:-1]

config = {
        "backend": {"db_url": f"sqlite://{DB_PATH}/db.sqlite3"},
        "dtnd": {
            "host": "127.0.0.1",
            "node_id": "dtn://n1/",
            "port": 3000,
            "rest_path": "",
            "ws_path": "/ws",
        },
        "backoff": {
            "initial_wait": 0.1,
            "max_retries": 20,
            "reconnection_pause": 300,
            "constant_wait": 0.75,
        },
        "bundles": {"lifetime": 86400000, "delivery_notification": False, "compress_body": True},
        "usenet": {
            "expiry_time": 2419200000,
            "email": SENDER_EMAIL,
            "newsgroups": [
                "monntpy.eval",
            ],
        },
    }
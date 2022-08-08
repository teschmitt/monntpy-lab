from logging import Logger
from pathlib import Path
import os

from toml import load

from logger import global_logger

logger: Logger = global_logger()


##################### Special variables for running this in CORE Emu Lab:

SENDER_EMAIL = os.environ.get('SENDER_EMAIL')
# NODE_ID = os.environ.get('NODE_ID')

#########################################################################


try:
    toml_path: str = str(Path(__file__).resolve().parent / "config.toml")
    config = load(toml_path)

    config["usenet"]["email"] = SENDER_EMAIL
except FileNotFoundError:
    logger.error("File 'config.toml' not found in backend root directory. Using defaults.")
    config = {
        "dtnd": {
            "host": "http://127.0.0.1",
            "port": 3000,
            "rest_path": "",
            "ws_path": "/ws",
        },
        "bundles": {"lifetime": "86400000", "deliv_notification": "false"},
    }

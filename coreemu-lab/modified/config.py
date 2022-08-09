from logging import Logger
from pathlib import Path
import os
import subprocess

from toml import load

from logger import global_logger

logger: Logger = global_logger()


"""
For running this in CORE Emu Lab, we need to change some of moNNT.py's configuration
This enables us to load a standard config.toml into the applications working path
and then substitute some elements with dynamically generated values that are taken
from the environment or passed to start-monttpy.sh

"""

SENDER_EMAIL = os.environ.get('SENDER_EMAIL')
SESSION_DIR = os.environ.get('SESSION_DIR')
HOSTNAME = subprocess.run(["hostname"], stdout=subprocess.PIPE).stdout.decode().strip()


toml_path: str = str(Path(__file__).resolve().parent / "config.toml")
config = load(toml_path)

config["usenet"]["email"] = SENDER_EMAIL
config["backend"]["db_url"] = f"sqlite://{SESSION_DIR}/{HOSTNAME}.conf/db.sqlite3"

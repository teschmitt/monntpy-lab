#!/bin/sh
set -eux

cd /app/moNNT.py
# poetry shell
export VIRTUAL_ENV=$(poetry env info --path)
python3 -m venv $VIRTUAL_ENV
export PATH="$VIRTUAL_ENV/bin:$PATH"
python main.py

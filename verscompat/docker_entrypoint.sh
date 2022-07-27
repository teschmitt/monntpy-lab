#!/bin/sh
set -eux

cd /app/moNNT.py

echo "Starting moNNT.py NNT Server ..."
poetry run python main.py

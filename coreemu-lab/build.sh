#!/bin/sh

rsync -aPz --exclude '*.pyc' --exclude '__pycache__' --exclude ".git" --exclude ".idea" --exclude ".ipynb_checkpoints" \
    /home/thomas/thesis/moNNT.py .
rsync -aPz --exclude '*.pyc' --exclude '__pycache__' --exclude ".git" --exclude ".idea" --exclude ".ipynb_checkpoints" \
    /home/thomas/thesis/py-dtn7 .

docker build --rm --tag monntpy-eval .

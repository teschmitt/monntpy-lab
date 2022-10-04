#!/bin/bash

# rsync -aPz -aPz --exclude '*.pyc' --exclude ".git" --exclude ".idea" --exclude ".ipynb_checkpoints" \
#       /home/thomas/thesis/moNNT.py .

git clone git@github.com:teschmitt/moNNT.py.git

docker build . --tag monntpy-bench
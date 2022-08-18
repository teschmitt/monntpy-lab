#!/bin/bash

rsync -aPz -aPz --exclude '*.pyc' --exclude ".git" --exclude ".idea" --exclude ".ipynb_checkpoints" \
      /home/thomas/thesis/moNNT.py .

docker build . --tag monntpy-bench
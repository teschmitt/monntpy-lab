#!/bin/sh

rsync -aPz --exclude '*.pyc' /home/thomas/thesis/moNNT.py .
rsync -aPz --exclude '*.pyc' /home/thomas/thesis/py-dtn7 .

docker build --rm --tag monntpy-eval .

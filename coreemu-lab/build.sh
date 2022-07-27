#!/bin/sh

rsync -aPz /home/thomas/thesis/moNNT.py .
rsync -aPz /home/thomas/thesis/py-dtn7 .

docker build --rm --tag monntpy-eval .

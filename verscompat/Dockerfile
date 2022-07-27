FROM python:3.8-slim

RUN pip install poetry==1.1.13

RUN mkdir -p /app/moNNT.py && mkdir -p /app/py-dtn7

COPY ./moNNT.py/ /app/moNNT.py
COPY ./py-dtn7/ /app/py-dtn7
WORKDIR /app/moNNT.py
RUN poetry install --no-interaction --no-ansi --no-root --no-dev

COPY docker_entrypoint.sh /

ENTRYPOINT ["/docker_entrypoint.sh"]

FROM rust:1.62.1 as builder
WORKDIR /root
RUN git clone https://github.com/dtn7/dtn7-rs && \
    cd dtn7-rs && \
    git checkout 0bb1fa3 && \
    cargo install --locked --bins --examples --root /usr/local --path examples && \
    cargo install --locked --bins --examples --root /usr/local --path core/dtn7


FROM python:3.10-slim

ENV DEBIAN_FRONTEND noninteractive
RUN apt update                              && \
    apt install -y bc git ripgrep psmisc    && \
    rm -rf /var/lib/apt/lists/*             && \
    pip install poetry==1.1.13

RUN mkdir -p /app/moNNT.py                  && \
    # mkdir /app/py_dtn7                      && \
    mkdir /app/articles                      && \
    mkdir /shared

# copy poetry files and do install first to avoid re-pulling PyPi packages on every
# change in the codebase
WORKDIR /app/moNNT.py
COPY ./moNNT.py/pyproject.toml ./moNNT.py/poetry.lock /app/moNNT.py/
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root --no-dev

# RUN git clone https://github.com/teschmitt/moNNT.py.git . && \   <-- reinstate this someday
COPY ./moNNT.py/ /app/moNNT.py
# COPY ./py-dtn7/ /app/py-dtn7
RUN rm -rf db.sqlite3*
# RUN poetry config virtualenvs.create false && \
#     poetry install --no-interaction --no-ansi --no-root --no-dev

COPY monntpy-config.py /app/moNNT.py/backend/dtn7sqlite/config.py
COPY spool.py /app
COPY articles/ /app/articles
COPY --from=builder /usr/local/bin/* /usr/local/bin/

COPY perf_eval.sh /

ENTRYPOINT ["/perf_eval.sh"]

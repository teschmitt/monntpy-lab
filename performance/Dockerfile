FROM rust:1.62.1 as builder
WORKDIR /root
RUN git clone https://github.com/dtn7/dtn7-rs && \
    cd dtn7-rs && \
    git checkout 0bb1fa3 && \
    cargo install --locked --bins --examples --root /usr/local --path examples && \
    cargo install --locked --bins --examples --root /usr/local --path core/dtn7


FROM python:3.10-slim

ENV DEBIAN_FRONTEND noninteractive
COPY docker /docker
RUN apt update                                                      && \
    apt install -y bc git ripgrep psmisc                            && \
    rm -rf /var/lib/apt/lists/*                                     && \
    pip install poetry==1.2.0                                       && \
    mkdir -p /app                                                   && \
    mkdir /shared                                                   && \
    cd /docker                                                      && \
    cp spool.py /app                                                && \
    cp -r articles/ /app/articles                                   && \
    cp perf_eval.sh /                                               && \
    cd /app                                                         && \
    git clone https://github.com/teschmitt/moNNT.py.git             && \
    cd /app/moNNT.py                                                && \
    poetry config virtualenvs.create false                          && \
    poetry install --no-interaction --no-ansi --no-root --only main && \
    cp /docker/monntpy-config.py /app/moNNT.py/backend/dtn7sqlite/config.py

COPY --from=builder /usr/local/bin/* /usr/local/bin/

ENTRYPOINT ["/perf_eval.sh"]

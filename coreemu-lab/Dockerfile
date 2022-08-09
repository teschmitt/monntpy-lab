# -----------------------------------------------------------------------------
FROM rust:1.58 as builder
WORKDIR /root
#RUN rustup component add rustfmt

RUN cargo install --locked --bins --examples --root /usr/local --git https://github.com/dtn7/dtn7-rs --rev 077d9a5 dtn7

# -----------------------------------------------------------------------------

FROM gh0st42/coreemu-lab:1.0.0
LABEL Description="Docker image for evaluating moNNT.py NNTP Server using core network emulator"


ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y bc && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/* /usr/local/bin/
# COPY bin/* /usr/local/bin/

RUN mkdir -p /root/.core/myservices && \
    mkdir -p /root/.coregui/custom_services && \
    mkdir -p /root/.coregui/icons


RUN echo "export USER=root" >> /root/.bashrc
ENV USER root

# --------------------------- moNNT.py Installation ---------------------------

RUN pip install poetry==1.1.13

# following commands rely on a moNNT.py installation copied to the current
# build environment
COPY ./moNNT.py/ /app/moNNT.py

# it is probably wise to substitute the above two lines with a git clone
# once the py-dtn7 package is fetched from PyPI instead of the local dev
# copy
WORKDIR /app/moNNT.py
RUN poetry install --no-interaction --no-ansi --no-root --no-dev

RUN mkdir -p /app/moNNT.py && mkdir /app/modified
COPY ./modified/* /app/modified/

# -----------------------------------------------------------------------------

COPY bin/* /usr/local/bin/

# exchange a few scripts
COPY scripts/entryPoint.sh      /root/entryPoint.sh

EXPOSE 22
EXPOSE 5901
EXPOSE 50051
